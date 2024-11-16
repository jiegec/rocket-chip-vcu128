#include <Vtestbench_rocketchip.h>
#include <arpa/inet.h>
#include <cstdint>
#include <fcntl.h>
#include <gmpxx.h>
#include <iostream>
#include <map>
#include <signal.h>
#include <sys/time.h>
#include <verilated.h>

#if VM_TRACE
#include <verilated_vcd_c.h> // Trace file format header
#endif

using namespace std;

// VGCDTester *top;
Vtestbench_rocketchip *top;

vluint64_t main_time =
    0; // Current simulation time
       // This is a 64-bit integer to reduce wrap over issues and
       // allow modulus.  You can also use a double, if you wish.

double sc_time_stamp() { // Called by $time in Verilog
  return main_time;      // converts to double, to match
                         // what SystemC does
}

// TODO Provide command-line options like vcd filename, timeout count, etc.
const long timeout = 1000000000L;

// memory mapping
typedef uint32_t mem_t;
std::map<uint64_t, mem_t> memory;

// align to mem_t boundary
uint64_t align(uint64_t addr) { return (addr / sizeof(mem_t)) * sizeof(mem_t); }

const uint64_t MEM_AXI_DATA_WIDTH = 64;
const uint64_t MEM_AXI_DATA_BYTES = MEM_AXI_DATA_WIDTH / 8;
const uint64_t MMIO_AXI_DATA_WIDTH = 64;
const uint64_t MMIO_AXI_DATA_BYTES = MMIO_AXI_DATA_WIDTH / 8;

// serial
// default at 0x60201000
uint64_t serial_addr = 0x60201000;

// axi ethernet
uint64_t emac_addr = 0x60400000;

// initialize signals
void init() {
  top->M_AXI_awready = 0;
  top->M_AXI_wready = 0;
  top->M_AXI_bvalid = 0;

  top->M_AXI_arready = 0;
  top->M_AXI_rvalid = 0;

  top->M_AXI_MMIO_awready = 0;
  top->M_AXI_MMIO_wready = 0;
  top->M_AXI_MMIO_bvalid = 0;

  top->M_AXI_MMIO_arready = 0;
  top->M_AXI_MMIO_rvalid = 0;
}

// step per clock fall
void step_mem() {
  // handle read
  static bool pending_read = false;
  static uint64_t pending_read_id = 0;
  static uint64_t pending_read_addr = 0;
  static uint64_t pending_read_len = 0;
  static uint64_t pending_read_size = 0;

  if (!pending_read) {
    if (top->M_AXI_arvalid) {
      top->M_AXI_arready = 1;
      pending_read = true;
      pending_read_id = top->M_AXI_arid;
      pending_read_addr = top->M_AXI_araddr;
      pending_read_len = top->M_AXI_arlen;
      pending_read_size = top->M_AXI_arsize;
    }

    top->M_AXI_rvalid = 0;
  } else {
    top->M_AXI_arready = 0;

    top->M_AXI_rvalid = 1;
    top->M_AXI_rid = pending_read_id;
    mpz_class r_data;

    uint64_t aligned =
        (pending_read_addr / MEM_AXI_DATA_BYTES) * MEM_AXI_DATA_BYTES;
    for (int i = 0; i < MEM_AXI_DATA_BYTES / sizeof(mem_t); i++) {
      uint64_t addr = aligned + i * sizeof(mem_t);
      mem_t r = memory[addr];
      mpz_class res = r;
      res <<= (i * (sizeof(mem_t) * 8));
      r_data += res;
    }

    mpz_class mask = 1;
    mask <<= (1L << pending_read_size) * 8;
    mask -= 1;

    mpz_class shifted_mask =
        mask << ((pending_read_addr & (MEM_AXI_DATA_BYTES - 1)) * 8);
    r_data &= shifted_mask;

    // top->M_AXI_rdata = r_data & shifted_mask;
    memset(&top->M_AXI_rdata, 0, sizeof(top->M_AXI_rdata));
    mpz_export(&top->M_AXI_rdata, NULL, -1, 4, -1, 0, r_data.get_mpz_t());
    top->M_AXI_rlast = pending_read_len == 0;

    // RREADY might be stale without eval()
    top->eval();
    if (top->M_AXI_rready) {
      if (pending_read_len == 0) {
        pending_read = false;
      } else {
        pending_read_addr += 1 << pending_read_size;
        pending_read_len--;
      }
    }
  }

  // handle write
  static bool pending_write = false;
  static bool pending_write_finished = false;
  static uint64_t pending_write_addr = 0;
  static uint64_t pending_write_len = 0;
  static uint64_t pending_write_size = 0;
  static uint64_t pending_write_id = 0;
  if (!pending_write) {
    // idle
    if (top->M_AXI_awvalid) {
      top->M_AXI_awready = 1;
      pending_write = true;
      pending_write_addr = top->M_AXI_awaddr;
      pending_write_len = top->M_AXI_awlen;
      pending_write_size = top->M_AXI_awsize;
      pending_write_id = top->M_AXI_awid;
      pending_write_finished = false;
    }
    top->M_AXI_wready = 0;
    top->M_AXI_bvalid = 0;
  } else if (!pending_write_finished) {
    // writing
    top->M_AXI_awready = 0;
    top->M_AXI_wready = 1;

    // WVALID might be stale without eval()
    top->eval();
    if (top->M_AXI_wvalid) {
      mpz_class mask = 1;
      mask <<= 1L << pending_write_size;
      mask -= 1;

      mpz_class shifted_mask =
          mask << (pending_write_addr & (MEM_AXI_DATA_BYTES - 1));
      mpz_class wdata;
      mpz_import(wdata.get_mpz_t(), MEM_AXI_DATA_BYTES / 4, -1, 4, -1, 0,
                 &top->M_AXI_wdata);

      uint64_t aligned =
          pending_write_addr / MEM_AXI_DATA_BYTES * MEM_AXI_DATA_BYTES;
      for (int i = 0; i < MEM_AXI_DATA_BYTES / sizeof(mem_t); i++) {
        uint64_t addr = aligned + i * sizeof(mem_t);

        mpz_class local_wdata_mpz = wdata >> (i * (sizeof(mem_t) * 8));
        mem_t local_wdata = local_wdata_mpz.get_ui();

        uint64_t local_wstrb = (top->M_AXI_wstrb >> (i * sizeof(mem_t))) & 0xfL;

        mpz_class local_mask_mpz = shifted_mask >> (i * sizeof(mem_t));
        uint64_t local_mask = local_mask_mpz.get_ui() & 0xfL;
        if (local_mask & local_wstrb) {
          mem_t base = memory[addr];
          mem_t input = local_wdata;
          uint64_t be = local_mask & local_wstrb;

          mem_t muxed = 0;
          for (int i = 0; i < sizeof(mem_t); i++) {
            mem_t sel;
            if (((be >> i) & 1) == 1) {
              sel = (input >> (i * 8)) & 0xff;
            } else {
              sel = (base >> (i * 8)) & 0xff;
            }
            muxed |= (sel << (i * 8));
          }

          memory[addr] = muxed;
        }
      }

      uint64_t input = wdata.get_ui();
      pending_write_addr += 1L << pending_write_size;
      pending_write_len--;
      if (top->M_AXI_wlast) {
        assert(pending_write_len == -1);
        pending_write_finished = true;
      }
    }

    top->M_AXI_bvalid = 0;
  } else {
    // finishing
    top->M_AXI_awready = 0;
    top->M_AXI_wready = 0;
    top->M_AXI_bvalid = 1;
    top->M_AXI_bresp = 0;
    top->M_AXI_bid = pending_write_id;

    // BREADY might be stale without eval()
    top->eval();
    if (top->M_AXI_bready) {
      pending_write = false;
      pending_write_finished = false;
    }
  }
}

// step per clock fall
void step_mmio() {
  // handle read
  static bool pending_read = false;
  static uint64_t pending_read_id = 0;
  static uint64_t pending_read_addr = 0;
  static uint64_t pending_read_len = 0;
  static uint64_t pending_read_size = 0;

  if (!pending_read) {
    if (top->M_AXI_MMIO_arvalid) {
      top->M_AXI_MMIO_arready = 1;
      pending_read = true;
      pending_read_id = top->M_AXI_MMIO_arid;
      pending_read_addr = top->M_AXI_MMIO_araddr;
      pending_read_len = top->M_AXI_MMIO_arlen;
      pending_read_size = top->M_AXI_MMIO_arsize;
    }

    top->M_AXI_MMIO_rvalid = 0;
  } else {
    top->M_AXI_MMIO_arready = 0;

    top->M_AXI_MMIO_rvalid = 1;
    top->M_AXI_MMIO_rid = pending_read_id;
    mpz_class r_data;
    if (pending_read_addr == serial_addr + 0x14) {
      // serial lsr
      // THRE | TEMT
      uint64_t lsr = (1L << 5) | (1L << 6);
      r_data = lsr << 32;
    } else if (pending_read_addr == serial_addr ||
               pending_read_addr == serial_addr + 0xc) {
      // ignored
      r_data = 0;
    } else if (pending_read_addr == emac_addr + 0x504) {
      // MDIO Control Word (0x504)
      // bit 7: MDIO ready
      r_data = (uint64_t)(1 << 7) << 32;
    } else if (pending_read_addr == emac_addr + 0x50c) {
      // MDIO Read Data (0x50C)
      // bit 16: MDIO ready
      r_data = (uint64_t)(1 << 16) << 32;
    } else if (pending_read_addr == emac_addr + 0x704) {
      // Unicast Address Word 1
      r_data = 0;
    } else {
      printf("Unhandled mmio read from %lx\n", pending_read_addr);
      r_data = 0;
    }

    mpz_class mask = 1;
    mask <<= (1L << pending_read_size) * 8;
    mask -= 1;

    mpz_class shifted_mask =
        mask << ((pending_read_addr & (MMIO_AXI_DATA_BYTES - 1)) * 8);
    r_data &= shifted_mask;

    // top->M_AXI_MMIO_RDATA = r_data & shifted_mask;
    memset(&top->M_AXI_MMIO_rdata, 0, sizeof(top->M_AXI_MMIO_rdata));
    mpz_export(&top->M_AXI_MMIO_rdata, NULL, -1, 4, -1, 0, r_data.get_mpz_t());
    top->M_AXI_MMIO_rlast = pending_read_len == 0;

    // RREADY might be stale without eval()
    top->eval();
    if (top->M_AXI_MMIO_rready) {
      if (pending_read_len == 0) {
        pending_read = false;
      } else {
        pending_read_addr += 1 << pending_read_size;
        pending_read_len--;
      }
    }
  }

  // handle write
  static bool pending_write = false;
  static bool pending_write_finished = false;
  static uint64_t pending_write_addr = 0;
  static uint64_t pending_write_len = 0;
  static uint64_t pending_write_size = 0;
  static uint64_t pending_write_id = 0;
  if (!pending_write) {
    if (top->M_AXI_MMIO_awvalid) {
      top->M_AXI_MMIO_awready = 1;
      pending_write = 1;
      pending_write_addr = top->M_AXI_MMIO_awaddr;
      pending_write_len = top->M_AXI_MMIO_awlen;
      pending_write_size = top->M_AXI_MMIO_awsize;
      pending_write_id = top->M_AXI_MMIO_awid;
      pending_write_finished = 0;
    }
    top->M_AXI_MMIO_wready = 0;
    top->M_AXI_MMIO_bvalid = 0;
  } else if (!pending_write_finished) {
    top->M_AXI_MMIO_awready = 0;
    top->M_AXI_MMIO_wready = 1;

    // WVALID might be stale without eval()
    top->eval();
    if (top->M_AXI_MMIO_wvalid) {
      mpz_class mask = 1;
      mask <<= 1L << pending_write_size;
      mask -= 1;

      mpz_class shifted_mask =
          mask << (pending_write_addr & (MMIO_AXI_DATA_BYTES - 1));
      mpz_class wdata;
      mpz_import(wdata.get_mpz_t(), MMIO_AXI_DATA_BYTES / 4, -1, 4, -1, 0,
                 &top->M_AXI_MMIO_wdata);

      uint64_t input = wdata.get_ui();
      static bool dlab = 0;
      // serial
      if (pending_write_addr == serial_addr) {
        if (!dlab) {
          printf("%c", (char)(input & 0xFF));
          fflush(stdout);
        }
      } else if (pending_write_addr == serial_addr + 0x4 ||
                 pending_write_addr == serial_addr + 0x8 ||
                 pending_write_addr == serial_addr + 0x10 ||
                 pending_write_addr == serial_addr + 0x1c) {
        // ignored
      } else if (pending_write_addr == serial_addr + 0xc) {
        dlab = ((input >> 32) >> 7) & 1;
      } else if (pending_write_addr == emac_addr + 0x500) {
        // MDIO Setup Word (0x500)
      } else if (pending_write_addr == emac_addr + 0x504) {
        // MDIO Control Word (0x504)
      } else if (pending_write_addr == emac_addr + 0x700) {
        // Unicast Address Word 0
      } else if (pending_write_addr == emac_addr + 0x704) {
        // Unicast Address Word 1
      } else {
        printf("Unhandled mmio write to %lx\n", pending_write_addr);
      }

      pending_write_addr += 1L << pending_write_size;
      pending_write_len--;
      if (top->M_AXI_MMIO_wlast) {
        assert(pending_write_len == -1);
        pending_write_finished = true;
      }
    }

    top->M_AXI_MMIO_bvalid = 0;
  } else {
    // finishing
    top->M_AXI_MMIO_awready = 0;
    top->M_AXI_MMIO_wready = 0;
    top->M_AXI_MMIO_bvalid = 1;
    top->M_AXI_MMIO_bresp = 0;
    top->M_AXI_MMIO_bid = pending_write_id;

    // BREADY might be stale without eval()
    top->eval();
    if (top->M_AXI_MMIO_bready) {
      pending_write = false;
      pending_write_finished = false;
    }
  }
}

// load file
void load_file(const std::string &path) {
  // load as bin
  FILE *fp = fopen(path.c_str(), "rb");
  assert(fp);
  uint64_t addr = 0x80000000;

  // read whole file and pad to multiples of mem_t
  fseek(fp, 0, SEEK_END);
  size_t size = ftell(fp);
  fseek(fp, 0, SEEK_SET);
  size_t padded_size = align(size + sizeof(mem_t) - 1);
  uint8_t *buffer = new uint8_t[padded_size];
  memset(buffer, 0, padded_size);

  size_t offset = 0;
  while (!feof(fp)) {
    ssize_t read = fread(&buffer[offset], 1, size - offset, fp);
    if (read <= 0) {
      break;
    }
    offset += read;
  }

  for (int i = 0; i < padded_size; i += sizeof(mem_t)) {
    memory[addr + i] = *((mem_t *)&buffer[i]);
  }
  fprintf(stderr, "> Loaded %ld bytes from BIN %s\n", size, path.c_str());
  fclose(fp);
  delete[] buffer;
}

uint64_t get_time_us() {
  struct timeval tv = {};
  gettimeofday(&tv, NULL);
  return tv.tv_sec * 1000000 + tv.tv_usec;
}

bool finished = false;

void ctrlc_handler(int arg) {
  cout << "Received Ctrl-C" << endl;
  finished = true;
}

int main(int argc, char **argv) {
  Verilated::commandArgs(argc, argv); // Remember args
  bool trace = false;
  char opt;
  while ((opt = getopt(argc, argv, "t")) != -1) {
    switch (opt) {
    case 't':
      trace = true;
      break;
    default: /* '?' */
      fprintf(stderr, "Usage: %s [-t] memory_content\n", argv[0]);
      return 1;
    }
  }

  if (optind >= argc) {
    fprintf(stderr, "Usage: %s [-t] memory_content\n", argv[0]);
    return 1;
  }

  load_file(argv[optind]);
  top = new Vtestbench_rocketchip;

  signal(SIGINT, ctrlc_handler);

#if VM_TRACE // If verilator was invoked with --trace
  VerilatedVcdC *tfp = NULL;
  if (trace) {
    Verilated::traceEverOn(true); // Verilator must compute traced signals
    VL_PRINTF("Enabling waves...\n");
    tfp = new VerilatedVcdC;
    top->trace(tfp, 99);   // Trace 99 levels of hierarchy
    tfp->open("dump.vcd"); // Open the dump file
  }
#endif

  top->reset = 1;

  // jtag
  // ref rocket chip remote_bitbang.cc
  int listen_fd = socket(AF_INET, SOCK_STREAM, 0);
  if (listen_fd < 0) {
    perror("socket");
    return -1;
  }

  // set non blocking
  fcntl(listen_fd, F_SETFL, O_NONBLOCK);

  int reuseaddr = 1;
  if (setsockopt(listen_fd, SOL_SOCKET, SO_REUSEADDR, &reuseaddr, sizeof(int)) <
      0) {
    perror("setsockopt");
    return -1;
  }

  int port = 12345;
  struct sockaddr_in addr = {};
  addr.sin_family = AF_INET;
  addr.sin_addr.s_addr = INADDR_ANY;
  addr.sin_port = htons(port);

  if (bind(listen_fd, (struct sockaddr *)&addr, sizeof(addr)) < 0) {
    perror("bind");
    return -1;
  }

  if (listen(listen_fd, 1) == -1) {
    perror("listen");
    return -1;
  }

  // init
  int client_fd = -1;
  top->jtag_TCK = 1;
  top->jtag_TMS = 1;
  top->jtag_TDI = 1;

  cout << "Starting simulation!\n";

  uint64_t begin = get_time_us();
  uint64_t clocks = 0;
  while (!Verilated::gotFinish() && main_time < timeout && !finished) {
    if (main_time > 1000) {
      top->reset = 0; // Deassert reset
    }
    if ((main_time % 10) == 1) {
      clocks++;
      top->clock = 1; // Toggle clock
    }
    if ((main_time % 10) == 6) {
      top->clock = 0;
      step_mem();
      step_mmio();
    }
    top->eval(); // Evaluate model
#if VM_TRACE
    if (tfp)
      tfp->dump(main_time); // Create waveform trace for this timestamp
#endif
    main_time++; // Time passes...

    if ((main_time % 50) == 0) {
      // jtag tick
      if (client_fd >= 0) {
        static char read_buffer[128];
        static size_t read_buffer_count = 0;
        static size_t read_buffer_offset = 0;

        if (read_buffer_offset == read_buffer_count) {
          ssize_t num_read = read(client_fd, read_buffer, sizeof(read_buffer));
          if (num_read > 0) {
            read_buffer_count = num_read;
            read_buffer_offset = 0;
          }
        }

        if (read_buffer_offset < read_buffer_count) {
          char command = read_buffer[read_buffer_offset++];
          if ('0' <= command && command <= '7') {
            // set
            char offset = command - '0';
            top->jtag_TCK = (offset >> 2) & 1;
            top->jtag_TMS = (offset >> 1) & 1;
            top->jtag_TDI = (offset >> 0) & 1;
          } else if (command == 'R') {
            // read
            char send = top->jtag_TDO ? '1' : '0';

            while (1) {
              ssize_t sent = write(client_fd, &send, sizeof(send));
              if (sent > 0) {
                break;
              } else if (send < 0) {
                close(client_fd);
                client_fd = -1;
                break;
              }
            }
          } else if (command == 'r' || command == 's') {
            // trst = 0;
          } else if (command == 't' || command == 'u') {
            // trst = 1;
          }
        }
      } else {
        // accept connection
        client_fd = accept(listen_fd, NULL, NULL);
        if (client_fd > 0) {
          fcntl(client_fd, F_SETFL, O_NONBLOCK);
          fprintf(stderr, "> JTAG debugger attached\n");
        }
      }
    }
  }

  uint64_t elapsed_us = get_time_us() - begin;
  if (main_time >= timeout) {
    cout << "Simulation terminated by timeout at time " << main_time
         << " (cycle " << main_time / 10 << ")" << endl;
    return -1;
  } else {
    cout << "Simulation completed at time " << main_time << " (cycle "
         << main_time / 10 << ")" << endl;
  }
  cout << "Simulation speed " << (double)clocks * 1000000 / elapsed_us
       << " mcycle/s" << endl;

  // Run for 10 more clocks
  vluint64_t end_time = main_time + 100;
  while (main_time < end_time) {
    if ((main_time % 10) == 1) {
      top->clock = 1; // Toggle clock
    }
    if ((main_time % 10) == 6) {
      top->clock = 0;
    }
    top->eval(); // Evaluate model
#if VM_TRACE
    if (tfp)
      tfp->dump(main_time); // Create waveform trace for this timestamp
#endif
    main_time++; // Time passes...
  }

#if VM_TRACE
  if (tfp)
    tfp->close();
#endif
}

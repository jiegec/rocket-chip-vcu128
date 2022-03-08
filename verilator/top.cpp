#include <Vtestbench_rocketchip.h>
#include <arpa/inet.h>
#include <fcntl.h>
#include <iostream>
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
const long timeout = 100000000L;

int main(int argc, char **argv) {
  Verilated::commandArgs(argc, argv); // Remember args
  top = new Vtestbench_rocketchip;

#if VM_TRACE                    // If verilator was invoked with --trace
  Verilated::traceEverOn(true); // Verilator must compute traced signals
  VL_PRINTF("Enabling waves...\n");
  VerilatedVcdC *tfp = new VerilatedVcdC;
  top->trace(tfp, 99);   // Trace 99 levels of hierarchy
  tfp->open("dump.vcd"); // Open the dump file
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

  while (!Verilated::gotFinish() && main_time < timeout) {
    if (main_time > 10) {
      top->reset = 0; // Deassert reset
    }
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

  if (main_time >= timeout) {
    cout << "Simulation terminated by timeout at time " << main_time
         << " (cycle " << main_time / 10 << ")" << endl;
    return -1;
  } else {
    cout << "Simulation completed at time " << main_time << " (cycle "
         << main_time / 10 << ")" << endl;
  }

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

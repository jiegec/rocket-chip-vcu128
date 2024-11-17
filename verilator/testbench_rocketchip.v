//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/05/2019 12:21:36 PM
// Design Name: 
// Module Name: testbench_rocketchip
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module testbench_rocketchip(
    clock,
    reset,
    interrupts,

    // MEM
    M_AXI_awready,
    M_AXI_awvalid,
    M_AXI_awid,
    M_AXI_awaddr,
    M_AXI_awlen,
    M_AXI_awsize,
    M_AXI_awburst,
    M_AXI_awlock,
    M_AXI_awcache,
    M_AXI_awprot,
    M_AXI_awqos,

    M_AXI_wready,
    M_AXI_wvalid,
    M_AXI_wdata,
    M_AXI_wstrb,
    M_AXI_wlast,

    M_AXI_bready,
    M_AXI_bvalid,
    M_AXI_bid,
    M_AXI_bresp,

    M_AXI_arready,
    M_AXI_arvalid,
    M_AXI_arid,
    M_AXI_araddr,
    M_AXI_arlen,
    M_AXI_arsize,
    M_AXI_arburst,
    M_AXI_arlock,
    M_AXI_arcache,
    M_AXI_arprot,
    M_AXI_arqos,

    M_AXI_rready,
    M_AXI_rvalid,
    M_AXI_rid,
    M_AXI_rdata,
    M_AXI_rresp,
    M_AXI_rlast,

    // MMIO
    M_AXI_MMIO_awready,
    M_AXI_MMIO_awvalid,
    M_AXI_MMIO_awid,
    M_AXI_MMIO_awaddr,
    M_AXI_MMIO_awlen,
    M_AXI_MMIO_awsize,
    M_AXI_MMIO_awburst,
    M_AXI_MMIO_awlock,
    M_AXI_MMIO_awcache,
    M_AXI_MMIO_awprot,
    M_AXI_MMIO_awqos,

    M_AXI_MMIO_wready,
    M_AXI_MMIO_wvalid,
    M_AXI_MMIO_wdata,
    M_AXI_MMIO_wstrb,
    M_AXI_MMIO_wlast,

    M_AXI_MMIO_bready,
    M_AXI_MMIO_bvalid,
    M_AXI_MMIO_bid,
    M_AXI_MMIO_bresp,

    M_AXI_MMIO_arready,
    M_AXI_MMIO_arvalid,
    M_AXI_MMIO_arid,
    M_AXI_MMIO_araddr,
    M_AXI_MMIO_arlen,
    M_AXI_MMIO_arsize,
    M_AXI_MMIO_arburst,
    M_AXI_MMIO_arlock,
    M_AXI_MMIO_arcache,
    M_AXI_MMIO_arprot,
    M_AXI_MMIO_arqos,

    M_AXI_MMIO_rready,
    M_AXI_MMIO_rvalid,
    M_AXI_MMIO_rid,
    M_AXI_MMIO_rdata,
    M_AXI_MMIO_rresp,
    M_AXI_MMIO_rlast,

    // JTAG
    jtag_TCK,
    jtag_TMS,
    jtag_TDI,
    jtag_TDO
    );

    input clock;
    input reset;
    input [5:0] interrupts;
    
    // MEM
    input M_AXI_awready;
    output M_AXI_awvalid;
    output [4:0] M_AXI_awid;
    output [63:0] M_AXI_awaddr;
    output [7:0] M_AXI_awlen;
    output [2:0] M_AXI_awsize;
    output [1:0] M_AXI_awburst;
    output M_AXI_awlock;
    output [3:0] M_AXI_awcache;
    output [2:0] M_AXI_awprot;
    output [3:0] M_AXI_awqos;

    input M_AXI_wready;
    output M_AXI_wvalid;
    output [63:0] M_AXI_wdata;
    output [7:0] M_AXI_wstrb;
    output M_AXI_wlast;

    output M_AXI_bready;
    input M_AXI_bvalid;
    input [4:0] M_AXI_bid;
    input [1:0] M_AXI_bresp;

    input M_AXI_arready;
    output M_AXI_arvalid;
    output [4:0] M_AXI_arid;
    output [63:0] M_AXI_araddr;
    output [7:0] M_AXI_arlen;
    output [2:0] M_AXI_arsize;
    output [1:0] M_AXI_arburst;
    output M_AXI_arlock;
    output [3:0] M_AXI_arcache;
    output [2:0] M_AXI_arprot;
    output [3:0] M_AXI_arqos;

    output M_AXI_rready;
    input M_AXI_rvalid;
    input [4:0] M_AXI_rid;
    input [63:0] M_AXI_rdata;
    input [1:0] M_AXI_rresp;
    input M_AXI_rlast;

    // MMIO
    input M_AXI_MMIO_awready;
    output M_AXI_MMIO_awvalid;
    output [4:0] M_AXI_MMIO_awid;
    output [63:0] M_AXI_MMIO_awaddr;
    output [7:0] M_AXI_MMIO_awlen;
    output [2:0] M_AXI_MMIO_awsize;
    output [1:0] M_AXI_MMIO_awburst;
    output M_AXI_MMIO_awlock;
    output [3:0] M_AXI_MMIO_awcache;
    output [2:0] M_AXI_MMIO_awprot;
    output [3:0] M_AXI_MMIO_awqos;

    input M_AXI_MMIO_wready;
    output M_AXI_MMIO_wvalid;
    output [63:0] M_AXI_MMIO_wdata;
    output [7:0] M_AXI_MMIO_wstrb;
    output M_AXI_MMIO_wlast;

    output M_AXI_MMIO_bready;
    input M_AXI_MMIO_bvalid;
    input [4:0] M_AXI_MMIO_bid;
    input [1:0] M_AXI_MMIO_bresp;

    input M_AXI_MMIO_arready;
    output M_AXI_MMIO_arvalid;
    output [4:0] M_AXI_MMIO_arid;
    output [63:0] M_AXI_MMIO_araddr;
    output [7:0] M_AXI_MMIO_arlen;
    output [2:0] M_AXI_MMIO_arsize;
    output [1:0] M_AXI_MMIO_arburst;
    output M_AXI_MMIO_arlock;
    output [3:0] M_AXI_MMIO_arcache;
    output [2:0] M_AXI_MMIO_arprot;
    output [3:0] M_AXI_MMIO_arqos;

    output M_AXI_MMIO_rready;
    input M_AXI_MMIO_rvalid;
    input [4:0] M_AXI_MMIO_rid;
    input [63:0] M_AXI_MMIO_rdata;
    input [1:0] M_AXI_MMIO_rresp;
    input M_AXI_MMIO_rlast;

    // jtag
    input jtag_TCK;
    input jtag_TMS;
    input jtag_TDI;
    output jtag_TDO;

    rocketchip_wrapper dut (
        .clk(clock),
        .reset(reset),
        .interrupts(interrupts),

        .M_AXI_awready(M_AXI_awready),
        .M_AXI_awvalid(M_AXI_awvalid),
        .M_AXI_awid(M_AXI_awid),
        .M_AXI_awaddr(M_AXI_awaddr),
        .M_AXI_awlen(M_AXI_awlen),
        .M_AXI_awsize(M_AXI_awsize),
        .M_AXI_awburst(M_AXI_awburst),
        .M_AXI_awlock(M_AXI_awlock),
        .M_AXI_awcache(M_AXI_awcache),
        .M_AXI_awprot(M_AXI_awprot),
        .M_AXI_awqos(M_AXI_awqos),

        .M_AXI_wready(M_AXI_wready),
        .M_AXI_wvalid(M_AXI_wvalid),
        .M_AXI_wdata(M_AXI_wdata),
        .M_AXI_wstrb(M_AXI_wstrb),
        .M_AXI_wlast(M_AXI_wlast),

        .M_AXI_bready(M_AXI_bready),
        .M_AXI_bvalid(M_AXI_bvalid),
        .M_AXI_bid(M_AXI_bid),
        .M_AXI_bresp(M_AXI_bresp),

        .M_AXI_arready(M_AXI_arready),
        .M_AXI_arvalid(M_AXI_arvalid),
        .M_AXI_arid(M_AXI_arid),
        .M_AXI_araddr(M_AXI_araddr),
        .M_AXI_arlen(M_AXI_arlen),
        .M_AXI_arsize(M_AXI_arsize),
        .M_AXI_arburst(M_AXI_arburst),
        .M_AXI_arlock(M_AXI_arlock),
        .M_AXI_arcache(M_AXI_arcache),
        .M_AXI_arprot(M_AXI_arprot),
        .M_AXI_arqos(M_AXI_arqos),

        .M_AXI_rready(M_AXI_rready),
        .M_AXI_rvalid(M_AXI_rvalid),
        .M_AXI_rid(M_AXI_rid),
        .M_AXI_rdata(M_AXI_rdata),
        .M_AXI_rresp(M_AXI_rresp),
        .M_AXI_rlast(M_AXI_rlast),

        .M_AXI_MMIO_awready(M_AXI_MMIO_awready),
        .M_AXI_MMIO_awvalid(M_AXI_MMIO_awvalid),
        .M_AXI_MMIO_awid(M_AXI_MMIO_awid),
        .M_AXI_MMIO_awaddr(M_AXI_MMIO_awaddr),
        .M_AXI_MMIO_awlen(M_AXI_MMIO_awlen),
        .M_AXI_MMIO_awsize(M_AXI_MMIO_awsize),
        .M_AXI_MMIO_awburst(M_AXI_MMIO_awburst),
        .M_AXI_MMIO_awlock(M_AXI_MMIO_awlock),
        .M_AXI_MMIO_awcache(M_AXI_MMIO_awcache),
        .M_AXI_MMIO_awprot(M_AXI_MMIO_awprot),
        .M_AXI_MMIO_awqos(M_AXI_MMIO_awqos),

        .M_AXI_MMIO_wready(M_AXI_MMIO_wready),
        .M_AXI_MMIO_wvalid(M_AXI_MMIO_wvalid),
        .M_AXI_MMIO_wdata(M_AXI_MMIO_wdata),
        .M_AXI_MMIO_wstrb(M_AXI_MMIO_wstrb),
        .M_AXI_MMIO_wlast(M_AXI_MMIO_wlast),

        .M_AXI_MMIO_bready(M_AXI_MMIO_bready),
        .M_AXI_MMIO_bvalid(M_AXI_MMIO_bvalid),
        .M_AXI_MMIO_bid(M_AXI_MMIO_bid),
        .M_AXI_MMIO_bresp(M_AXI_MMIO_bresp),

        .M_AXI_MMIO_arready(M_AXI_MMIO_arready),
        .M_AXI_MMIO_arvalid(M_AXI_MMIO_arvalid),
        .M_AXI_MMIO_arid(M_AXI_MMIO_arid),
        .M_AXI_MMIO_araddr(M_AXI_MMIO_araddr),
        .M_AXI_MMIO_arlen(M_AXI_MMIO_arlen),
        .M_AXI_MMIO_arsize(M_AXI_MMIO_arsize),
        .M_AXI_MMIO_arburst(M_AXI_MMIO_arburst),
        .M_AXI_MMIO_arlock(M_AXI_MMIO_arlock),
        .M_AXI_MMIO_arcache(M_AXI_MMIO_arcache),
        .M_AXI_MMIO_arprot(M_AXI_MMIO_arprot),
        .M_AXI_MMIO_arqos(M_AXI_MMIO_arqos),

        .M_AXI_MMIO_rready(M_AXI_MMIO_rready),
        .M_AXI_MMIO_rvalid(M_AXI_MMIO_rvalid),
        .M_AXI_MMIO_rid(M_AXI_MMIO_rid),
        .M_AXI_MMIO_rdata(M_AXI_MMIO_rdata),
        .M_AXI_MMIO_rresp(M_AXI_MMIO_rresp),
        .M_AXI_MMIO_rlast(M_AXI_MMIO_rlast),

        .S_AXI_awvalid(1'b0),
        .S_AXI_wvalid(1'b0),
        .S_AXI_bready(1'b0),
        .S_AXI_arvalid(1'b0),
        .S_AXI_rready(1'b0),

        .jtag_TCK(jtag_TCK),
        .jtag_TMS(jtag_TMS),
        .jtag_TDI(jtag_TDI),
        .jtag_TDO(jtag_TDO)
    );
endmodule

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
    input clock,
    input reset,

    input jtag_TCK,
    input jtag_TMS,
    input jtag_TDI,
    output jtag_TDO
    );
    
    // MEM
    wire M_AXI_awready;
    wire M_AXI_awvalid;
    wire [4:0] M_AXI_awid;
    wire [63:0] M_AXI_awaddr;
    wire [7:0] M_AXI_awlen;
    wire [2:0] M_AXI_awsize;
    wire [1:0] M_AXI_awburst;
    wire M_AXI_awlock;
    wire [3:0] M_AXI_awcache;
    wire [2:0] M_AXI_awprot;
    wire [3:0] M_AXI_awqos;

    wire M_AXI_wready;
    wire M_AXI_wvalid;
    wire [63:0] M_AXI_wdata;
    wire [7:0] M_AXI_wstrb;
    wire M_AXI_wlast;

    wire M_AXI_bready;
    wire M_AXI_bvalid;
    wire [4:0] M_AXI_bid;
    wire [1:0] M_AXI_bresp;

    wire M_AXI_arready;
    wire M_AXI_arvalid;
    wire [4:0] M_AXI_arid;
    wire [63:0] M_AXI_araddr;
    wire [7:0] M_AXI_arlen;
    wire [2:0] M_AXI_arsize;
    wire [1:0] M_AXI_arburst;
    wire M_AXI_arlock;
    wire [3:0] M_AXI_arcache;
    wire [2:0] M_AXI_arprot;
    wire [3:0] M_AXI_arqos;

    wire M_AXI_rready;
    wire M_AXI_rvalid;
    wire [4:0] M_AXI_rid;
    wire [63:0] M_AXI_rdata;
    wire [1:0] M_AXI_rresp;
    wire M_AXI_rlast;

    axi_ram ram (
        .clk(clock),
        .rst(reset),

        .s_axi_awid(M_AXI_awid),
        .s_axi_awaddr(M_AXI_awaddr),
        .s_axi_awlen(M_AXI_awlen),
        .s_axi_awsize(M_AXI_awsize),
        .s_axi_awburst(M_AXI_awburst),
        .s_axi_awlock(M_AXI_awlock),
        .s_axi_awcache(M_AXI_awcache),
        .s_axi_awprot(M_AXI_awprot),
        .s_axi_awvalid(M_AXI_awvalid),
        .s_axi_awready(M_AXI_awready),

        .s_axi_wdata(M_AXI_wdata),
        .s_axi_wstrb(M_AXI_wstrb),
        .s_axi_wlast(M_AXI_wlast),
        .s_axi_wvalid(M_AXI_wvalid),
        .s_axi_wready(M_AXI_wready),
        
        .s_axi_bid(M_AXI_bid),
        .s_axi_bresp(M_AXI_bresp),
        .s_axi_bvalid(M_AXI_bvalid),
        .s_axi_bready(M_AXI_bready),
        
        .s_axi_arid(M_AXI_arid),
        .s_axi_araddr(M_AXI_araddr),
        .s_axi_arlen(M_AXI_arlen),
        .s_axi_arsize(M_AXI_arsize),
        .s_axi_arburst(M_AXI_arburst),
        .s_axi_arlock(M_AXI_arlock),
        .s_axi_arcache(M_AXI_arcache),
        .s_axi_arprot(M_AXI_arprot),
        .s_axi_arvalid(M_AXI_arvalid),
        .s_axi_arready(M_AXI_arready),
        
        .s_axi_rid(M_AXI_rid),
        .s_axi_rdata(M_AXI_rdata),
        .s_axi_rresp(M_AXI_rresp),
        .s_axi_rlast(M_AXI_rlast),
        .s_axi_rvalid(M_AXI_rvalid),
        .s_axi_rready(M_AXI_rready)
    );
    
    // MMIO
    wire M_AXI_MMIO_awready;
    wire M_AXI_MMIO_awvalid;
    wire [4:0] M_AXI_MMIO_awid;
    wire [63:0] M_AXI_MMIO_awaddr;
    wire [7:0] M_AXI_MMIO_awlen;
    wire [2:0] M_AXI_MMIO_awsize;
    wire [1:0] M_AXI_MMIO_awburst;
    wire M_AXI_MMIO_awlock;
    wire [3:0] M_AXI_MMIO_awcache;
    wire [2:0] M_AXI_MMIO_awprot;
    wire [3:0] M_AXI_MMIO_awqos;

    wire M_AXI_MMIO_wready;
    wire M_AXI_MMIO_wvalid;
    wire [63:0] M_AXI_MMIO_wdata;
    wire [7:0] M_AXI_MMIO_wstrb;
    wire M_AXI_MMIO_wlast;

    wire M_AXI_MMIO_bready;
    wire M_AXI_MMIO_bvalid;
    wire [4:0] M_AXI_MMIO_bid;
    wire [1:0] M_AXI_MMIO_bresp;

    wire M_AXI_MMIO_arready;
    wire M_AXI_MMIO_arvalid;
    wire [4:0] M_AXI_MMIO_arid;
    wire [63:0] M_AXI_MMIO_araddr;
    wire [7:0] M_AXI_MMIO_arlen;
    wire [2:0] M_AXI_MMIO_arsize;
    wire [1:0] M_AXI_MMIO_arburst;
    wire M_AXI_MMIO_arlock;
    wire [3:0] M_AXI_MMIO_arcache;
    wire [2:0] M_AXI_MMIO_arprot;
    wire [3:0] M_AXI_MMIO_arqos;

    wire M_AXI_MMIO_rready;
    wire M_AXI_MMIO_rvalid;
    wire [4:0] M_AXI_MMIO_rid;
    wire [63:0] M_AXI_MMIO_rdata;
    wire [1:0] M_AXI_MMIO_rresp;
    wire M_AXI_MMIO_rlast;

    axi_ram fake_mmio (
        .clk(clock),
        .rst(reset),

        .s_axi_awid(M_AXI_MMIO_awid),
        .s_axi_awaddr(M_AXI_MMIO_awaddr),
        .s_axi_awlen(M_AXI_MMIO_awlen),
        .s_axi_awsize(M_AXI_MMIO_awsize),
        .s_axi_awburst(M_AXI_MMIO_awburst),
        .s_axi_awlock(M_AXI_MMIO_awlock),
        .s_axi_awcache(M_AXI_MMIO_awcache),
        .s_axi_awprot(M_AXI_MMIO_awprot),
        .s_axi_awvalid(M_AXI_MMIO_awvalid),
        .s_axi_awready(M_AXI_MMIO_awready),

        .s_axi_wdata(M_AXI_MMIO_wdata),
        .s_axi_wstrb(M_AXI_MMIO_wstrb),
        .s_axi_wlast(M_AXI_MMIO_wlast),
        .s_axi_wvalid(M_AXI_MMIO_wvalid),
        .s_axi_wready(M_AXI_MMIO_wready),
        
        .s_axi_bid(M_AXI_MMIO_bid),
        .s_axi_bresp(M_AXI_MMIO_bresp),
        .s_axi_bvalid(M_AXI_MMIO_bvalid),
        .s_axi_bready(M_AXI_MMIO_bready),
        
        .s_axi_arid(M_AXI_MMIO_arid),
        .s_axi_araddr(M_AXI_MMIO_araddr),
        .s_axi_arlen(M_AXI_MMIO_arlen),
        .s_axi_arsize(M_AXI_MMIO_arsize),
        .s_axi_arburst(M_AXI_MMIO_arburst),
        .s_axi_arlock(M_AXI_MMIO_arlock),
        .s_axi_arcache(M_AXI_MMIO_arcache),
        .s_axi_arprot(M_AXI_MMIO_arprot),
        .s_axi_arvalid(M_AXI_MMIO_arvalid),
        .s_axi_arready(M_AXI_MMIO_arready),
        
        .s_axi_rid(M_AXI_MMIO_rid),
        .s_axi_rdata(M_AXI_MMIO_rdata),
        .s_axi_rresp(M_AXI_MMIO_rresp),
        .s_axi_rlast(M_AXI_MMIO_rlast),
        .s_axi_rvalid(M_AXI_MMIO_rvalid),
        .s_axi_rready(M_AXI_MMIO_rready)
    );

    rocketchip_wrapper dut (
        .clk(clock),
        .reset(reset),
        .interrupts(0),

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

        .jtag_TCK(jtag_TCK),
        .jtag_TMS(jtag_TMS),
        .jtag_TDI(jtag_TDI),
        .jtag_TDO(jtag_TDO)
    );
endmodule

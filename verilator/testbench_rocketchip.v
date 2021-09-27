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
    input reset
    );

    rocketchip_wrapper dut (
        .clk(clock),
        .reset(reset),
        .interrupts(0),
        .M_AXI_awready(0),
        .M_AXI_wready(0),
        .M_AXI_bvalid(0),
        .M_AXI_bid(0),
        .M_AXI_bresp(0),
        .M_AXI_arready(0),
        .M_AXI_rvalid(0),
        .M_AXI_rid(0),
        .M_AXI_rdata(0),
        .M_AXI_rresp(0),
        .M_AXI_rlast(0),
        .M_AXI_MMIO_awready(0),
        .M_AXI_MMIO_wready(0),
        .M_AXI_MMIO_bvalid(0),
        .M_AXI_MMIO_bid(0),
        .M_AXI_MMIO_bresp(0),
        .M_AXI_MMIO_arready(0),
        .M_AXI_MMIO_rvalid(0),
        .M_AXI_MMIO_rid(0),
        .M_AXI_MMIO_rdata(0),
        .M_AXI_MMIO_rresp(0),
        .M_AXI_MMIO_rlast(0)
    );
endmodule

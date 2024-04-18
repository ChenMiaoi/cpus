`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/17/2024 11:16:41 PM
// Design Name: 
// Module Name: mips_sopc
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
`include "./defines.v"

module mips_sopc(
    input wire  clk,
    input wire  rst
    );

    wire [`INST_ADDR_BUS]   inst_addr;
    wire [`INST_BUS]        inst;
    wire                    rom_en;

    mips_cpu cpu0(
        .clk(clk),              .rst(rst),
        .i_rom_data(inst),
        .o_rom_en(rom_en),      .o_rom_addr(inst_addr)
    );

    inst_rom inst_rom0(
        .i_pc_en(rom_en),
        .i_pc_addr(inst_addr),     .o_fetch_inst(inst)
    );
endmodule

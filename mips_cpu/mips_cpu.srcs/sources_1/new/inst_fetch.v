`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/16/2024 02:55:19 PM
// Design Name: 
// Module Name: inst_fetch
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

module inst_fetch(
    input   wire                            rst,
    input   wire                            clk,
    input   wire    [`INST_ADDR_BUS]        i_rom_pc,               // the addr of the instruction attached in instruction fetch 
    input   wire    [`INST_BUS]             i_rom_inst,             // the instruction attached in instruction fetch
    output  reg     [`INST_ADDR_BUS]        o_inst_decode_pc,       // the addr of the instruction for instruction decode
    output  reg     [`INST_BUS]             o_inst_decode_inst      // the instruction for instruction decode
    );

    always @(posedge clk) begin
        if (rst == `RST_ENABLE) begin
            o_inst_decode_pc   <= `ZERO_WORD;
            o_inst_decode_inst <= `ZERO_WORD;
        end else begin
            o_inst_decode_pc   <= i_rom_pc;
            o_inst_decode_inst <= i_rom_inst;
        end
    end
endmodule

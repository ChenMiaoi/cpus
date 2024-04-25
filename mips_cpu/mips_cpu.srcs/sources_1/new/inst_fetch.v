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
    
    //! 新增：来自CTRL模块信号
    input   wire    [5:0]                   i_stall_req,

    output  reg     [`INST_ADDR_BUS]        o_inst_decode_pc,       // the addr of the instruction for instruction decode
    output  reg     [`INST_BUS]             o_inst_decode_inst      // the instruction for instruction decode
    );

    //! 当i_stall_req[1]为STOP，i_stall_req[2]不为时，表示取指阶段暂停，译码阶段继续，因此需要使用空指令进入下一个周期
    //! 当i_stall_req[1]为0时，取指阶段继续
    always @(posedge clk) begin
        if (rst == `RST_ENABLE) begin
            o_inst_decode_pc   <= `ZERO_WORD;
            o_inst_decode_inst <= `ZERO_WORD;
        end else if (i_stall_req[1] == `STOP_DISABLE && 
                    i_stall_req[2] == `STOP_DISABLE) begin
            o_inst_decode_pc   <= `ZERO_WORD;
            o_inst_decode_inst <= `ZERO_WORD;
        end else if (i_stall_req[1] == `STOP_DISABLE) begin
            o_inst_decode_pc   <= i_rom_pc;
            o_inst_decode_inst <= i_rom_inst;
        end
    end
endmodule

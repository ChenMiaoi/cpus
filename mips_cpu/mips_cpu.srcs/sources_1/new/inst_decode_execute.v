`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/17/2024 08:32:55 PM
// Design Name: 
// Module Name: inst_decode_excute
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

module inst_decode_execute(
    input   wire                        rst,
    input   wire                        clk,

    input   wire    [`ALU_SEL_BUS]      i_inst_decode_alu_sel,
    input   wire    [`ALU_OP_BUS]       i_inst_decode_alu_op,
    input   wire    [`REG_BUS]          i_inst_decode_reg_data1,
    input   wire    [`REG_BUS]          i_inst_decode_reg_data2,
    input   wire    [`REG_ADDR_BUS]     i_inst_decode_w_reg_addr,
    input   wire                        i_inst_decode_w_reg_en,

    //! 新增：来自CTRL模块的信号
    input   wire    [5:0]               i_stall_req,

    output  reg     [`ALU_SEL_BUS]      o_execute_alu_sel,
    output  reg     [`ALU_OP_BUS]       o_execute_alu_op,
    output  reg     [`REG_BUS]          o_execute_reg_data1,
    output  reg     [`REG_BUS]          o_execute_reg_data2,
    output  reg     [`REG_ADDR_BUS]     o_execute_w_reg_addr,
    output  reg                         o_execute_w_reg_en
    );

    //! 当i_stall_req[2]为STOP，i_stall_req[3]为0时，表示译码阶段暂停，执行阶段继续，因此使用空指令进入一下周期
    //! 当i_stall_req[2]为0时，译码阶段继续，译码后的指令进入执行姐u但
    always @(posedge clk) begin
        if (rst == `RST_ENABLE) begin
            o_execute_alu_op        <= `EXE_NOP_OP;
            o_execute_alu_sel       <= `EXE_RES_NOP;
            o_execute_reg_data1     <= `ZERO_WORD;
            o_execute_reg_data2     <= `ZERO_WORD;
            o_execute_w_reg_addr    <= `NOP_REG_ADDR;
            o_execute_w_reg_en      <= `WRITE_DISABLE;
        end else if (i_stall_req[2] == `STOP_ENABLE && i_stall_req[3] == `STOP_DISABLE) begin
            o_execute_alu_op        <= `EXE_NOP_OP;
            o_execute_alu_sel       <= `EXE_RES_NOP;
            o_execute_reg_data1     <= `ZERO_WORD;
            o_execute_reg_data2     <= `ZERO_WORD;
            o_execute_w_reg_addr    <= `NOP_REG_ADDR;
            o_execute_w_reg_en      <= `WRITE_DISABLE;
        end else if (i_stall_req[2] == `STOP_DISABLE) begin
            o_execute_alu_op        <= i_inst_decode_alu_op;
            o_execute_alu_sel       <= i_inst_decode_alu_sel;
            o_execute_reg_data1     <= i_inst_decode_reg_data1;
            o_execute_reg_data2     <= i_inst_decode_reg_data2;
            o_execute_w_reg_addr    <= i_inst_decode_w_reg_addr;
            o_execute_w_reg_en      <= i_inst_decode_w_reg_en;
        end
    end
endmodule

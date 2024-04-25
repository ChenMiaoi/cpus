`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/17/2024 10:00:04 PM
// Design Name: 
// Module Name: memmory_write_back
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

module memory_write_back(
    input   wire                        rst,
    input   wire                        clk,

    input   wire                        i_memory_w_reg_en,
    input   wire    [`REG_ADDR_BUS]     i_memory_w_reg_addr,
    input   wire    [`REG_BUS]          i_memory_w_reg_data,

    //! 新增：CTRL模块输入
    input   wire    [5:0]               i_stall_req,

    //! 新增：HILO模块输入
    input   wire                        i_memory_w_reg_hilo_en,
    input   wire    [`REG_BUS]          i_memory_w_reg_hi_data,
    input   wire    [`REG_BUS]          i_memory_w_reg_lo_data,

    //! 新增：HILO模块输出
    output  reg                         o_hilo_w_reg_hilo_en,
    output  reg     [`REG_BUS]          o_hilo_w_reg_hi_data,
    output  reg     [`REG_BUS]          o_hilo_w_reg_lo_data,

    output  reg                         o_regfile_w_reg_en,
    output  reg     [`REG_ADDR_BUS]     o_regfile_w_reg_addr,
    output  reg     [`REG_BUS]          o_regfile_w_reg_data
    );

    //! 当i_stall_req[4]为STOP，i_stall_req[5]为0时，访存阶段暂停，回写阶段继续
    //! 当i_stall_req[4]为0时，执行阶段继续
    always @(posedge clk) begin
        if (rst == `RST_ENABLE) begin
            o_regfile_w_reg_en      <= `WRITE_DISABLE;
            o_regfile_w_reg_addr    <= `NOP_REG_ADDR;
            o_regfile_w_reg_data    <= `ZERO_WORD;
            o_hilo_w_reg_hilo_en    <= `WRITE_DISABLE;
            o_hilo_w_reg_hi_data    <= `ZERO_WORD;
            o_hilo_w_reg_lo_data    <= `ZERO_WORD;
        end else if (i_stall_req[4] == `STOP_ENABLE && i_stall_req[5] == `STOP_DISABLE) begin
            o_regfile_w_reg_en      <= `WRITE_DISABLE;
            o_regfile_w_reg_addr    <= `NOP_REG_ADDR;
            o_regfile_w_reg_data    <= `ZERO_WORD;
            o_hilo_w_reg_hilo_en    <= `WRITE_DISABLE;
            o_hilo_w_reg_hi_data    <= `ZERO_WORD;
            o_hilo_w_reg_lo_data    <= `ZERO_WORD;
        end else if (i_stall_req[4] == `STOP_DISABLE) begin
            o_regfile_w_reg_en      <= i_memory_w_reg_en;
            o_regfile_w_reg_addr    <= i_memory_w_reg_addr;
            o_regfile_w_reg_data    <= i_memory_w_reg_data;
            o_hilo_w_reg_hilo_en    <= i_memory_w_reg_hilo_en;
            o_hilo_w_reg_hi_data    <= i_memory_w_reg_hi_data;
            o_hilo_w_reg_lo_data    <= i_memory_w_reg_lo_data;
        end
    end
endmodule

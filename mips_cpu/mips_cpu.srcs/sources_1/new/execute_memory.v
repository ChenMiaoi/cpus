`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/17/2024 09:51:48 PM
// Design Name: 
// Module Name: execute_memory
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

module execute_memory(
    input   wire                        rst,
    input   wire                        clk,
    
    input   wire                        i_execute_w_reg_en,
    input   wire    [`REG_ADDR_BUS]     i_execute_w_reg_addr,
    input   wire    [`REG_BUS]          i_execute_w_reg_data,

    //! 新增：HILO模块数据输入
    input   wire                        i_execute_w_reg_hilo_en,
    input   wire    [`REG_BUS]          i_execute_w_reg_hi_data,
    input   wire    [`REG_BUS]          i_execute_w_reg_lo_data,

    //! 新增：HILO模块数据输出
    output  reg                         o_memory_w_reg_hilo_en,
    output  reg     [`REG_BUS]          o_memory_w_reg_hi_data,
    output  reg     [`REG_BUS]          o_memory_w_reg_lo_data,

    
    output  reg                         o_memory_w_reg_en,
    output  reg     [`REG_ADDR_BUS]     o_memory_w_reg_addr,
    output  reg     [`REG_BUS]          o_memory_w_reg_data
    );

    always @(posedge clk) begin
        if (rst == `RST_ENABLE) begin
            o_memory_w_reg_en       <= `WRITE_DISABLE;
            o_memory_w_reg_addr     <= `NOP_REG_ADDR;
            o_memory_w_reg_data     <= `ZERO_WORD;
            o_memory_w_reg_hilo_en  <= `WRITE_DISABLE;
            o_memory_w_reg_hi_data  <= `ZERO_WORD;
            o_memory_w_reg_lo_data  <= `ZERO_WORD;
        end else begin
            o_memory_w_reg_en       <= i_execute_w_reg_en;
            o_memory_w_reg_addr     <= i_execute_w_reg_addr;
            o_memory_w_reg_data     <= i_execute_w_reg_data;
            o_memory_w_reg_hilo_en  <= i_execute_w_reg_hilo_en;
            o_memory_w_reg_hi_data  <= i_execute_w_reg_hi_data;
            o_memory_w_reg_lo_data  <= i_execute_w_reg_lo_data;
        end
    end
endmodule

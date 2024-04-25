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

    //! 新增：CTRL模块输入信号
    input   wire    [5:0]               i_stall_req,

    //! 新增：上一个周期得到的乘法结果
    input   wire    [`DOUBLE_REG_BUS]   i_hilo_temp,

    //! 新增：记录执行周期
    input   wire    [1:0]               i_clk_cnt,

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
    output  reg     [`REG_BUS]          o_memory_w_reg_data,

    //! 新增：上一个周期得到的乘法结果
    output  reg     [`DOUBLE_REG_BUS]   o_hilo_temp,

    //! 新增：记录执行周期
    output  reg     [1:0]               o_clk_cnt
    );

    //! 当i_stall_req[3]为STOP，i_stall_req[4]为0时，执行阶段暂停，访存阶段继续
    //! 当i_stall_req[3]为0时，执行阶段继续

    //! 新增：流水线执行暂停时，需要将上一个周期的乘法结果送出
    always @(posedge clk) begin
        if (rst == `RST_ENABLE) begin
            o_memory_w_reg_en       <= `WRITE_DISABLE;
            o_memory_w_reg_addr     <= `NOP_REG_ADDR;
            o_memory_w_reg_data     <= `ZERO_WORD;
            o_memory_w_reg_hilo_en  <= `WRITE_DISABLE;
            o_memory_w_reg_hi_data  <= `ZERO_WORD;
            o_memory_w_reg_lo_data  <= `ZERO_WORD;

            o_hilo_temp             <= { `ZERO_WORD, `ZERO_WORD };
            o_clk_cnt               <= 2'b00;
        end else if (i_stall_req[3] == `STOP_ENABLE && i_stall_req[4] == `STOP_DISABLE) begin
            o_memory_w_reg_en       <= `WRITE_DISABLE;
            o_memory_w_reg_addr     <= `NOP_REG_ADDR;
            o_memory_w_reg_data     <= `ZERO_WORD;
            o_memory_w_reg_hilo_en  <= `WRITE_DISABLE;
            o_memory_w_reg_hi_data  <= `ZERO_WORD;
            o_memory_w_reg_lo_data  <= `ZERO_WORD;

            o_hilo_temp             <= i_hilo_temp;
            o_clk_cnt               <= i_clk_cnt;
        end else if (i_stall_req[3] == `STOP_DISABLE) begin
            o_memory_w_reg_en       <= i_execute_w_reg_en;
            o_memory_w_reg_addr     <= i_execute_w_reg_addr;
            o_memory_w_reg_data     <= i_execute_w_reg_data;
            o_memory_w_reg_hilo_en  <= i_execute_w_reg_hilo_en;
            o_memory_w_reg_hi_data  <= i_execute_w_reg_hi_data;
            o_memory_w_reg_lo_data  <= i_execute_w_reg_lo_data;

            o_hilo_temp             <= { `ZERO_WORD, `ZERO_WORD };
            o_clk_cnt               <= 2'b00;
        end else begin
            o_hilo_temp             <= { `ZERO_WORD, `ZERO_WORD };
            o_clk_cnt               <= 2'b00;
        end
    end
endmodule

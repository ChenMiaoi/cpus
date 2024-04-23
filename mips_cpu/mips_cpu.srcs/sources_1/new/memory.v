`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/17/2024 09:57:08 PM
// Design Name: 
// Module Name: memory
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

module memory(
    input   wire 						rst,

    input   wire                        i_execute_w_reg_en,
    input   wire    [`REG_ADDR_BUS]     i_execute_w_reg_addr,
    input   wire    [`REG_BUS]          i_execute_w_reg_data,

    //! 新增：HILO模块输入
    input   wire                        i_execute_w_reg_hilo_en,
    input   wire    [`REG_BUS]          i_execute_w_reg_hi_data,
    input   wire    [`REG_BUS]          i_execute_w_reg_lo_data,

    //! 新增：HILO模块输出
    output  reg                         o_write_back_w_reg_hilo_en,
    output  reg     [`REG_BUS]          o_write_back_w_reg_hi_data,
    output  reg     [`REG_BUS]          o_write_back_w_reg_lo_data,

    output  reg                         o_write_back_w_reg_en,
    output  reg     [`REG_ADDR_BUS]     o_write_back_w_reg_addr,
    output  reg     [`REG_BUS]          o_write_back_w_reg_data
    );

	always @(*) begin
		if (rst == `RST_ENABLE) begin
			o_write_back_w_reg_en       <= `WRITE_DISABLE;
            o_write_back_w_reg_addr     <= `NOP_REG_ADDR;
            o_write_back_w_reg_data     <= `ZERO_WORD;
            o_write_back_w_reg_hilo_en  <= `WRITE_DISABLE;
            o_write_back_w_reg_hi_data  <= `ZERO_WORD;
            o_write_back_w_reg_lo_data  <= `ZERO_WORD;
        end else begin
            o_write_back_w_reg_en       <= i_execute_w_reg_en;
            o_write_back_w_reg_addr     <= i_execute_w_reg_addr;
            o_write_back_w_reg_data     <= i_execute_w_reg_data;
            o_write_back_w_reg_hilo_en  <= i_execute_w_reg_hilo_en;
            o_write_back_w_reg_hi_data  <= i_execute_w_reg_hi_data;
            o_write_back_w_reg_lo_data  <= i_execute_w_reg_lo_data;
		end
	end
endmodule

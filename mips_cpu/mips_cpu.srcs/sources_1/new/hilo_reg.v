`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/23/2024 02:43:48 PM
// Design Name: 
// Module Name: hilo_reg
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

module hilo_reg(
    input   wire                    rst,
    input   wire                    clk,
    input   wire                    i_w_hilo_reg_en,
    input   wire    [`REG_BUS]      i_w_hi_reg_data,
    input   wire    [`REG_BUS]      i_w_lo_reg_data,

    output  reg     [`REG_BUS]      o_hi_reg_data,
    output  reg     [`REG_BUS]      o_lo_reg_data
    );

    always @(posedge clk) begin
        if (rst == `RST_ENABLE) begin
            o_hi_reg_data <= `ZERO_WORD;
            o_lo_reg_data <= `ZERO_WORD;
        end else if (i_w_hilo_reg_en == `WRITE_ENABLE) begin
            o_hi_reg_data <= i_w_hi_reg_data;
            o_lo_reg_data <= i_w_lo_reg_data;
        end
    end
endmodule

`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/17/2024 09:41:02 PM
// Design Name: 
// Module Name: excute
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

module execute(
    input   wire                    rst,
    input   wire  [`ALU_SEL_BUS]    i_inst_decode_alu_sel,
    input   wire  [`ALU_OP_BUS]     i_inst_decode_alu_op,
    input   wire  [`REG_BUS]        i_inst_decode_reg_data1,
    input   wire  [`REG_BUS]        i_inst_decode_reg_data2,
    input   wire  [`REG_ADDR_BUS]   i_inst_decode_w_reg_addr,
    input   wire                    i_inst_decode_w_reg_en,
    output  reg                     o_w_reg_en,
    output  reg   [`REG_ADDR_BUS]   o_w_reg_addr,
    output  reg   [`REG_BUS]        o_w_reg_data
    );

    reg [`REG_BUS] logic_out;

    always @(*) begin
        if (rst == `RST_ENABLE) begin
            logic_out <= `ZERO_WORD;
        end else begin
            case (i_inst_decode_alu_op)
                `EXE_OR_OP: begin
                    logic_out <= i_inst_decode_reg_data1 | i_inst_decode_reg_data2;
                end 
                default: begin
                    logic_out <= `ZERO_WORD;
                end
            endcase
        end
    end

    always @(*) begin
        o_w_reg_addr <= i_inst_decode_w_reg_addr;
        o_w_reg_en  <= i_inst_decode_w_reg_en;
        case (i_inst_decode_alu_sel)
            `EXE_RES_LOGIC: begin
                o_w_reg_data <= logic_out;
            end
            default: begin
                o_w_reg_data <= `ZERO_WORD;
            end
        endcase
    end
endmodule

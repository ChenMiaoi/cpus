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

    //! 新增：HI、LO寄存器接口，以及处理HI、LO带来的RAW
    input   wire  [`REG_BUS]        i_hilo_reg_hi_data,
    input   wire  [`REG_BUS]        i_hilo_reg_lo_data,

    //! 新增：来自于Memory阶段处理的RAW的数据
    input   wire                    i_mem_w_reg_hilo_en,
    input   wire  [`REG_BUS]        i_mem_w_reg_hi_data,
    input   wire  [`REG_BUS]        i_mem_w_reg_lo_data,
    
    //! 新增：来自于Write Back阶段处理的RAW数据
    input   wire                    i_write_back_w_reg_hilo_en,
    input   wire  [`REG_BUS]        i_write_back_w_reg_hi_data,
    input   wire  [`REG_BUS]        i_write_back_w_reg_lo_data,

    //! 新增：是否要保存的HILO数据
    output  reg                     o_w_reg_hilo_en,
    output  reg   [`REG_BUS]        o_w_reg_hi_data,
    output  reg   [`REG_BUS]        o_w_reg_lo_data,

    output  reg                     o_w_reg_en,
    output  reg   [`REG_ADDR_BUS]   o_w_reg_addr,
    output  reg   [`REG_BUS]        o_w_reg_data
    );

    reg [`REG_BUS] logic_out;
    reg [`REG_BUS] shift_res;
    reg [`REG_BUS] move_res;
    reg [`REG_BUS] hi;
    reg [`REG_BUS] lo;

    always @(*) begin
        if (rst == `RST_ENABLE) begin
            logic_out <= `ZERO_WORD;
        end else begin
            case (i_inst_decode_alu_op)
                `EXE_OR_OP: begin
                    logic_out <= i_inst_decode_reg_data1 | i_inst_decode_reg_data2;
                end 
                `EXE_AND_OP: begin
                    logic_out <= i_inst_decode_reg_data1 & i_inst_decode_reg_data2;
                end
                `EXE_NOR_OP: begin
                    logic_out <= ~(i_inst_decode_reg_data1 | i_inst_decode_reg_data2);
                end 
                `EXE_XOR_OP: begin
                    logic_out <= i_inst_decode_reg_data1 ^ i_inst_decode_reg_data2;
                end
                default: begin
                    logic_out <= `ZERO_WORD;
                end
            endcase
        end
    end

    always @(*) begin
        if (rst == `RST_ENABLE) begin
            shift_res <= `ZERO_WORD;
        end else begin
            case (i_inst_decode_alu_op)
                `EXE_SLL_OP: begin
                    shift_res <= i_inst_decode_reg_data2 << i_inst_decode_reg_data1[4:0];
                end 
                `EXE_SRL_OP: begin
                    shift_res <= i_inst_decode_reg_data2 >> i_inst_decode_reg_data1[4:0];
                end
                `EXE_SRA_OP: begin
                    shift_res <= ({32{i_inst_decode_reg_data2[31]}} << (6'd32 - { 1'b0, i_inst_decode_reg_data1[4:0] }))
                                | i_inst_decode_reg_data2 >> i_inst_decode_reg_data1[4:0]; 
                end
                default: begin
                    shift_res <= `ZERO_WORD;
                end 
            endcase 
        end
    end

    //! 新增：处理HILO模块
    always @(*) begin
        if (rst == `RST_ENABLE) begin
            { hi, lo } <= { `ZERO_WORD, `ZERO_WORD };
        end else if (i_mem_w_reg_hilo_en == `WRITE_ENABLE) begin            //! 针对于Memory模块导致的RAW问题
            { hi, lo } <= { i_mem_w_reg_hi_data, i_mem_w_reg_lo_data };
        end else if (i_write_back_w_reg_hilo_en == `WRITE_ENABLE) begin     //! 针对于Write Back模块导致的RAW问题
            { hi, lo } <= { i_write_back_w_reg_hi_data, i_write_back_w_reg_lo_data };
        end else begin
            { hi, lo } <= { i_hilo_reg_hi_data, i_hilo_reg_lo_data };
        end
    end

    //! 新增：处理MF、MOVE类型
    always @(*) begin
        if (rst == `RST_ENABLE) begin
            move_res <= `ZERO_WORD;
        end else begin
            move_res <= `ZERO_WORD;
            case (i_inst_decode_alu_op)
                `EXE_MFHI_OP: begin
                    move_res <= hi;
                end 
                `EXE_MFLO_OP: begin
                    move_res <= lo;
                end
                `EXE_MOVZ_OP: begin
                    move_res <= i_inst_decode_reg_data1;
                end
                `EXE_MOVN_OP: begin
                    move_res <= i_inst_decode_reg_data1;
                end 
                default: begin
                end
            endcase
        end
    end

    //! 新增处理MT类型
    always @(*) begin
        if (rst == `RST_ENABLE) begin
            o_w_reg_hilo_en <= `WRITE_DISABLE;
            o_w_reg_hi_data <= `ZERO_WORD;
            o_w_reg_lo_data <= `ZERO_WORD;
        end else if (i_inst_decode_alu_op == `EXE_MTHI_OP) begin
            o_w_reg_hilo_en <= `WRITE_ENABLE;
            o_w_reg_hi_data <= i_inst_decode_reg_data1;
            o_w_reg_lo_data <= lo;
        end else if (i_inst_decode_alu_op == `EXE_MTLO_OP) begin
            o_w_reg_hilo_en <= `WRITE_ENABLE;
            o_w_reg_hi_data <= hi;
            o_w_reg_lo_data <= i_inst_decode_reg_data1;
        end else begin
            o_w_reg_hilo_en <= `WRITE_DISABLE;
            o_w_reg_hi_data <= `ZERO_WORD;
            o_w_reg_lo_data <= `ZERO_WORD;
        end
    end 

    always @(*) begin
        o_w_reg_addr <= i_inst_decode_w_reg_addr;
        o_w_reg_en   <= i_inst_decode_w_reg_en;
        case (i_inst_decode_alu_sel)
            `EXE_RES_LOGIC: begin
                o_w_reg_data <= logic_out;
            end
            `EXE_RES_SHIFT: begin
                o_w_reg_data <= shift_res; 
            end
            `EXE_RES_MOVE: begin
                o_w_reg_data <= move_res;
            end
            default: begin
                o_w_reg_data <= `ZERO_WORD;
            end
        endcase
    end
endmodule

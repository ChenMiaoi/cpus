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

    //! 新增：上一个周期得到的乘法结果
    input   wire  [`DOUBLE_REG_BUS] i_hilo_temp,

    //! 新增：记录执行周期
    input   wire  [1:0]             i_clk_cnt,

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
    output  reg   [`REG_BUS]        o_w_reg_data,

    //! 新增：对CTRL的输出信号
    output  reg                     o_stall_req,

    //! 新增：上一个周期得到的乘法结果
    output  reg   [`DOUBLE_REG_BUS] o_hilo_temp,

    //! 新增：记录执行周期
    output  reg   [1:0]             o_clk_cnt
    );

    reg [`REG_BUS] logic_out;
    reg [`REG_BUS] shift_res;
    reg [`REG_BUS] move_res;
    reg [`REG_BUS] hi;
    reg [`REG_BUS] lo;

    //! 新增：变量
    wire                    is_overflow;        //! 计算过程中是否发生溢出标志位
    wire [`REG_BUS]         i_reg_data1_not;    //! 第一个操作数取反值
    wire [`REG_BUS]         i_reg_data2_mux;    //! 第二个操作数补码值
    wire                    is_reg1_eq_reg2;    //! 第一个操作数是否与第二个相等
    wire                    is_reg1_lt_reg2;    //! 第一个操作数是否小于第二个
    wire [`REG_BUS]         mul_opdata1;        //! 被乘数
    wire [`REG_BUS]         mul_opdata2;        //! 乘数
    wire [`DOUBLE_REG_BUS]  hilo_temp;          //! 临时保存乘法结果

    wire [`REG_BUS]         result_sum;         //! 保存加法结果
    reg [`REG_BUS]          arithmetic_res;     //! 算数运算结果
    reg [`DOUBLE_REG_BUS]   mul_res;            //! 保存乘法结果
    reg [`DOUBLE_REG_BUS]   hilo_temp_first;    //! 保存上一个周期结果
    reg                     stall_req;          //! 针对于MADD、MSUB类型的暂停

    //! 如果是减法或有符号比较运算，那么就需要对第二个操作数做补码
    assign i_reg_data2_mux = ((i_inst_decode_alu_op == `EXE_SUB_OP) ||
                              (i_inst_decode_alu_op == `EXE_SUBU_OP) ||
                              (i_inst_decode_alu_op == `EXE_SLT_OP)) ?
                              (~i_inst_decode_reg_data2) + 1 : i_inst_decode_reg_data2;

    //! 1. 如果是加法，此时i_reg_data2_mux就是第二个操作数，因此result_sum就是其结果
    //! 2. 如果是减法，此时i_reg_data2_mux就是第二个操作数，因此result_sum就是其结果
    //! 3. 如果是有符号比较，此时i_reg_data2_mux就是第二个操作数，因此直接判断result_sum是否小于零
    assign result_sum = i_inst_decode_reg_data1 + i_reg_data2_mux;

    //! 计算溢出
    //!     1. 如果都为正数，但结果为负数，则溢出
    //!     2. 如果都为负数，但结果为正数，则溢出
    assign is_overflow = 
        ((!i_inst_decode_reg_data1[31] && !i_reg_data2_mux[31]) &&
        result_sum[31]) ||
        ((i_inst_decode_reg_data1[31] && i_reg_data2_mux[31]) &&
        !result_sum[31]);

    //! 计算小于
    //! 1. 如果操作类型是EXE_SLT_OP则是有符号
    //!     a. 如果第一个操作数为负数，第二个正数，那么显然第一小于第二
    //!     b. 如果第一个操作数为正数，第二个正数，当result_sum为负时，才表示其小于
    //!     c. 如果第一个操作数为负数，第二个负数，当result_sum为负时，也为小于
    //! 2. 如果为无符号，直接比较即可
    assign is_reg1_lt_reg2 = ((i_inst_decode_alu_op == `EXE_SLT_OP)) ?
        ((i_inst_decode_reg_data1[31] && !i_inst_decode_reg_data2[31]) ||
        (!i_inst_decode_reg_data1[31] && !i_inst_decode_reg_data2[31] && result_sum[31]) ||
        (i_inst_decode_reg_data1[31] && i_inst_decode_reg_data2[31] && result_sum[31]))
        : (i_inst_decode_reg_data1 < i_inst_decode_reg_data2);

    //! 对操作数取反
    assign i_reg_data1_not = ~i_inst_decode_reg_data1;

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
    //! 新增：算数运算对于MT类型
    //! 新增：处理MADD类型
    always @(*) begin
        if (rst == `RST_ENABLE) begin
            o_w_reg_hilo_en <= `WRITE_DISABLE;
            o_w_reg_hi_data <= `ZERO_WORD;
            o_w_reg_lo_data <= `ZERO_WORD;
        end else if (i_inst_decode_alu_op == `EXE_MULT_OP || i_inst_decode_alu_op == `EXE_MULTU_OP) begin
            o_w_reg_hilo_en <= `WRITE_ENABLE;
            o_w_reg_hi_data <= mul_res[63:32];
            o_w_reg_lo_data <= mul_res[31:0];
        end else if (i_inst_decode_alu_op == `EXE_MSUB_OP || i_inst_decode_alu_op == `EXE_MSUBU_OP) begin
            o_w_reg_hilo_en <= `WRITE_ENABLE;
            o_w_reg_hi_data <= hilo_temp_first[63:32];
            o_w_reg_lo_data <= hilo_temp_first[31:0];
        end else if (i_inst_decode_alu_op == `EXE_MADD_OP || i_inst_decode_alu_op == `EXE_MADDU_OP) begin
            o_w_reg_hilo_en <= `WRITE_ENABLE;
            o_w_reg_hi_data <= hilo_temp_first[63:32];
            o_w_reg_lo_data <= hilo_temp_first[31:0];
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

    //! 新增算数类型
    always @(*) begin
        if (rst == `RST_ENABLE) begin
            arithmetic_res <= `ZERO_WORD;
        end else begin
            case (i_inst_decode_alu_op)
                `EXE_SLT_OP, `EXE_SLTU_OP: begin
                    arithmetic_res <= is_reg1_lt_reg2;
                end 
                `EXE_ADD_OP, `EXE_ADDU_OP, `EXE_ADDI_OP, `EXE_ADDIU_OP: begin
                    arithmetic_res <= result_sum;
                end
                `EXE_SUB_OP, `EXE_SUBU_OP: begin
                    arithmetic_res <= result_sum;
                end
                `EXE_CLZ_OP: begin
                    arithmetic_res <= 
                        i_inst_decode_reg_data1[31] ? 0  : i_inst_decode_reg_data1[30] ? 1  : i_inst_decode_reg_data1[29] ? 2 :
                        i_inst_decode_reg_data1[28] ? 3  : i_inst_decode_reg_data1[27] ? 4  : i_inst_decode_reg_data1[26] ? 5 :
                        i_inst_decode_reg_data1[25] ? 6  : i_inst_decode_reg_data1[24] ? 7  : i_inst_decode_reg_data1[23] ? 8 : 
                        i_inst_decode_reg_data1[22] ? 9  : i_inst_decode_reg_data1[21] ? 10 : i_inst_decode_reg_data1[20] ? 11 :
                        i_inst_decode_reg_data1[19] ? 12 : i_inst_decode_reg_data1[18] ? 13 : i_inst_decode_reg_data1[17] ? 14 : 
                        i_inst_decode_reg_data1[16] ? 15 : i_inst_decode_reg_data1[15] ? 16 : i_inst_decode_reg_data1[14] ? 17 : 
                        i_inst_decode_reg_data1[13] ? 18 : i_inst_decode_reg_data1[12] ? 19 : i_inst_decode_reg_data1[11] ? 20 :
                        i_inst_decode_reg_data1[10] ? 21 : i_inst_decode_reg_data1[9]  ? 22 : i_inst_decode_reg_data1[8]  ? 23 : 
                        i_inst_decode_reg_data1[7]  ? 24 : i_inst_decode_reg_data1[6]  ? 25 : i_inst_decode_reg_data1[5]  ? 26 : 
                        i_inst_decode_reg_data1[4]  ? 27 : i_inst_decode_reg_data1[3]  ? 28 : i_inst_decode_reg_data1[2]  ? 29 : 
                        i_inst_decode_reg_data1[1]  ? 30 : i_inst_decode_reg_data1[0]  ? 31 : 32 ;
                end
                `EXE_CLO_OP: begin
                    arithmetic_res <= (
                        i_reg_data1_not[31] ? 0  : i_reg_data1_not[30] ? 1  : i_reg_data1_not[29] ? 2 :
                        i_reg_data1_not[28] ? 3  : i_reg_data1_not[27] ? 4  : i_reg_data1_not[26] ? 5 :
                        i_reg_data1_not[25] ? 6  : i_reg_data1_not[24] ? 7  : i_reg_data1_not[23] ? 8 : 
                        i_reg_data1_not[22] ? 9  : i_reg_data1_not[21] ? 10 : i_reg_data1_not[20] ? 11 :
                        i_reg_data1_not[19] ? 12 : i_reg_data1_not[18] ? 13 : i_reg_data1_not[17] ? 14 : 
                        i_reg_data1_not[16] ? 15 : i_reg_data1_not[15] ? 16 : i_reg_data1_not[14] ? 17 : 
                        i_reg_data1_not[13] ? 18 : i_reg_data1_not[12] ? 19 : i_reg_data1_not[11] ? 20 :
                        i_reg_data1_not[10] ? 21 : i_reg_data1_not[9]  ? 22 : i_reg_data1_not[8]  ? 23 : 
                        i_reg_data1_not[7]  ? 24 : i_reg_data1_not[6]  ? 25 : i_reg_data1_not[5]  ? 26 : 
                        i_reg_data1_not[4]  ? 27 : i_reg_data1_not[3]  ? 28 : i_reg_data1_not[2]  ? 29 : 
                        i_reg_data1_not[1]  ? 30 : i_reg_data1_not[0]  ? 31 : 32) ;
                end
                default: begin
                    arithmetic_res <= `ZERO_WORD;
                end
            endcase
        end
    end

    //! 新增乘法类型
    assign mul_opdata1 = 
        (((i_inst_decode_alu_op == `EXE_MUL_OP) || (i_inst_decode_alu_op == `EXE_MULT_OP) ||
        (i_inst_decode_alu_op == `EXE_MADD_OP) || (i_inst_decode_alu_op == `EXE_MSUB_OP)) &&
        (i_inst_decode_reg_data1[31] == 1'b1)) 
        ? (~i_inst_decode_reg_data1 + 1) : i_inst_decode_reg_data1;

    assign mul_opdata2 = 
        (((i_inst_decode_alu_op == `EXE_MUL_OP) || (i_inst_decode_alu_op == `EXE_MULT_OP) ||
        (i_inst_decode_alu_op == `EXE_MADD_OP) || (i_inst_decode_alu_op == `EXE_MSUB_OP)) &&
        (i_inst_decode_reg_data2[31] == 1'b1)) 
        ? (~i_inst_decode_reg_data2 + 1) : i_inst_decode_reg_data2;

    assign hilo_temp = mul_opdata1 * mul_opdata2;

    //! 新增：对临时乘法结果进行修正
    //  1. 如果是有符号乘法运算madd、msub，那么需要修正临时结果：
    //      a. 如果被乘数和乘数符号不同，那么需要求补码作为最终结果
    //      b. 如果同号，那么直接作为结果
    //  2. 如果是无符号，那么直接作为结果
    always @(*) begin
        if (rst == `RST_ENABLE) begin
            mul_res <= { `ZERO_WORD, `ZERO_WORD };
        end else if (i_inst_decode_alu_op == `EXE_MUL_OP || 
                    i_inst_decode_alu_op == `EXE_MULT_OP ||
                    i_inst_decode_alu_op == `EXE_MADD_OP || 
                    i_inst_decode_alu_op == `EXE_MSUB_OP) begin
            if (i_inst_decode_reg_data1[31] ^ i_inst_decode_reg_data2[31] == `TRUE_V) begin
                mul_res <= ~hilo_temp + 1;
            end else begin
                mul_res <= hilo_temp;
            end
        end else begin
            mul_res <= hilo_temp;
        end
    end

    //! 新增：MADD、MSUB指令处理
    always @(*) begin
        if (rst == `RST_ENABLE) begin
            o_hilo_temp <= { `ZERO_WORD, `ZERO_WORD };
            o_clk_cnt   <= 2'b00;
            stall_req   <= `STOP_DISABLE;
        end else begin
            case (i_inst_decode_alu_op)
                `EXE_MADD_OP, `EXE_MADDU_OP: begin
                    if (i_clk_cnt == 2'b00) begin           // 执行阶段的第一个时钟周期
                        o_hilo_temp     <= mul_res;
                        o_clk_cnt       <= 2'b01;
                        hilo_temp_first <= { `ZERO_WORD, `ZERO_WORD };
                        stall_req       <= `STOP_ENABLE;
                    end else if (i_clk_cnt == 2'b01) begin // 执行阶段的第二个时钟周期
                        o_hilo_temp     <= { `ZERO_WORD, `ZERO_WORD };
                        o_clk_cnt       <= 2'b10;
                        hilo_temp_first <= i_hilo_temp + { hi, lo };
                        stall_req       <= `STOP_DISABLE;
                    end
                end 
                `EXE_MSUB_OP, `EXE_MSUBU_OP: begin
                    if (i_clk_cnt == 2'b00) begin           // 执行阶段的第一个时钟周期
                        o_hilo_temp     <= ~mul_res + 1;
                        o_clk_cnt       <= 2'b01;
                        stall_req       <= `STOP_ENABLE;
                    end else if (i_clk_cnt == 2'b01) begin // 执行阶段的第二个时钟周期
                        o_hilo_temp     <= { `ZERO_WORD, `ZERO_WORD };
                        o_clk_cnt       <= 2'b10;
                        hilo_temp_first <= i_hilo_temp + { hi, lo };
                        stall_req       <= `STOP_DISABLE;
                    end
                end
                default: begin
                    o_hilo_temp     <= { `ZERO_WORD, `ZERO_WORD };
                    o_clk_cnt       <= 2'b00;
                    stall_req       <= `STOP_DISABLE;
                end 
            endcase
        end
    end

    //! 新增：暂停流水线
    always @(*) begin
        o_stall_req     <= stall_req; 
    end

    always @(*) begin
        o_w_reg_addr <= i_inst_decode_w_reg_addr;
        // o_w_reg_en   <= i_inst_decode_w_reg_en;
        if (((i_inst_decode_alu_op == `EXE_ADD_OP) || 
            (i_inst_decode_alu_op == `EXE_ADDI_OP) ||
            (i_inst_decode_alu_op == `EXE_SUB_OP)) && (is_overflow == `TRUE_V)) begin
            o_w_reg_en <= `WRITE_DISABLE;
        end else begin
            o_w_reg_en <= i_inst_decode_w_reg_en;
        end
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
            `EXE_RES_ARITHMETIC: begin
                o_w_reg_data <= arithmetic_res;
            end
            `EXE_RES_MUL: begin
                o_w_reg_data <= mul_res[31:0];
            end
            default: begin
                o_w_reg_data <= `ZERO_WORD;
            end
        endcase
    end
endmodule

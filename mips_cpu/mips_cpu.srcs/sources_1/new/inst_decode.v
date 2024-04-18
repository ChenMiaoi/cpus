`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/16/2024 04:06:59 PM
// Design Name: 
// Module Name: inst_decode
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

module inst_decode(
    input   wire                        rst,    
    input   wire    [`INST_ADDR_BUS]    i_fetch_pc,             //! the addr of the instruction whith need to be decoded
    input   wire    [`INST_BUS]         i_fetch_inst,           //! the instruction whith need to be decoded

    // read the regfile
    input   wire    [`REG_BUS]          i_regfile_reg_data1,    //! rs1's data
    input   wire    [`REG_BUS]          i_regfile_reg_data2,    //! rs2's data

    // output into regfile
    output  reg                         o_regfile_r_reg_en1,    //! the read enable signal for rs1 
    output  reg                         o_regfile_r_reg_en2,    //! the read enable signal for rs2
    output  reg     [`REG_ADDR_BUS]     o_regfile_r_reg_addr1,  //! the addr of rs1 which will be readed
    output  reg     [`REG_ADDR_BUS]     o_regfile_r_reg_addr2,  //! the addr of rs2 which will be readed

    // output into execution inst
    output  reg     [`ALU_OP_BUS]       o_execute_alu_op,       //! bit range operator code: logic、shift、algorithm
    output  reg     [`ALU_SEL_BUS]      o_execute_alu_sel,      //! small range operator code: and logic, or logic...
    output  reg     [`REG_BUS]          o_execute_reg_data1,    //! the rs1 which need to be calc
    output  reg     [`REG_BUS]          o_execute_reg_data2,    //! the rs2 which need to be calc
    output  reg     [`REG_ADDR_BUS]     o_execute_w_reg_addr,   //! the addr which need to be writen when calc done
    output  reg                         o_execute_w_reg_en      //! the write enable signal for rd
    );

    // for ori instruction:
    // 31       26 25       21 20       16 15                   0
    // ----------------------------------------------------------
    //     ORI    |    rs    |     rd    |          imme
    // ----------------------------------------------------------
    //   001101   |          |           |
    // ----------------------------------------------------------
    //! so, ori belongs to op
    //
    // another instruction type:
    // 31       26 25       21 20       16 15       11 10       6 5         0
    // ----------------------------------------------------------------------
    //     op     |     rs    |     rt    |     rd    |     sa   |   func   
    // ----------------------------------------------------------------------

    wire [5:0] op   = i_fetch_inst[31:26];
    wire [4:0] op1  = i_fetch_inst[10:6];
    wire [5:0] op2  = i_fetch_inst[5:0];
    wire [4:0] op3  = i_fetch_inst[20:16];

    reg [`REG_BUS] imm;
    reg inst_valid;

    // to init information
    always @(*) begin
        if (rst == `RST_ENABLE) begin
            o_execute_alu_op        <= `EXE_NOP_OP;
            o_execute_alu_sel       <= `EXE_RES_NOP;
            o_execute_w_reg_addr    <= `NOP_REG_ADDR;
            o_execute_w_reg_en      <= `WRITE_DISABLE;
            inst_valid              <= `INST_VALID;
            o_regfile_r_reg_en1     <= `READ_DISABLE;
            o_regfile_r_reg_en2     <= `READ_DISABLE;
            o_regfile_r_reg_addr1   <= `NOP_REG_ADDR;
            o_regfile_r_reg_addr2   <= `NOP_REG_ADDR;
            imm                     <= `ZERO_WORD;
        end else begin
            o_execute_alu_op        <= `EXE_NOP_OP;
            o_execute_alu_sel       <= `EXE_RES_NOP;
            o_execute_w_reg_addr    <= i_fetch_inst[15:11];
            o_execute_w_reg_en      <= `WRITE_DISABLE;
            inst_valid              <= `INST_INVALID;
            o_regfile_r_reg_en1     <= `READ_DISABLE;
            o_regfile_r_reg_en2     <= `READ_DISABLE;
            o_regfile_r_reg_addr1   <= i_fetch_inst[25:21];
            o_regfile_r_reg_addr2   <= i_fetch_inst[20:16];
            imm             <= `ZERO_WORD;

            // to configure each instruction individually
            case (op)
                `EXE_ORI: begin
                    o_execute_w_reg_en      <= `WRITE_ENABLE;               // write enable for rd
                    o_execute_alu_op        <= `EXE_OR_OP;                  // or logic instruction
                    o_execute_alu_sel       <= `EXE_RES_LOGIC;              // logic instruction
                    o_regfile_r_reg_en1     <= `READ_ENABLE;                // read enable for rs1
                    o_regfile_r_reg_en2     <= `READ_DISABLE;               // rs2 for imm, so don't need read enable
                    imm                     <= { 16'h0, i_fetch_inst[15:0] };     // unsigned extend for imm
                    o_execute_w_reg_addr    <= i_fetch_inst[20:16];               // rd's position
                    inst_valid              <= `INST_VALID;                 // valid instruction
                end
                default: begin
                end
            endcase
        end
    end


    // if rst is enable, rs1 and rs2 are all be reset
    //! if rs1(or rs2) is enable, read rs1(or rs2)'s data
    //! if rs1(or rs2) is disable, it repretend rs1(or rs2) is imme
    //! all other cases are assigned a value of 0
    always @(*) begin
        if (rst == `RST_ENABLE) begin
            o_execute_reg_data1 <= `ZERO_WORD;
        end else if(o_regfile_r_reg_en1 == `READ_ENABLE) begin
            o_execute_reg_data1 <= i_regfile_reg_data1;
        end else if(o_regfile_r_reg_en1 == `READ_DISABLE) begin
            o_execute_reg_data1 <= imm;
        end else begin
            o_execute_reg_data1 <= `ZERO_WORD;
        end
    end

    always @(*) begin
        if (rst == `RST_ENABLE) begin
            o_execute_reg_data2 <= `ZERO_WORD;
        end else if(o_regfile_r_reg_en2 == `READ_ENABLE) begin
            o_execute_reg_data2 <= i_regfile_reg_data2;
        end else if(o_regfile_r_reg_en2 == `READ_DISABLE) begin
            o_execute_reg_data2 <= imm;
        end else begin
            o_execute_reg_data2 <= `ZERO_WORD;
        end
    end
endmodule

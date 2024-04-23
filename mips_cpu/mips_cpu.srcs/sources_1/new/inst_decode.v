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

    // deal RAW data hazard in Execute stage
    input   wire                        i_execute_w_reg_en,
    input   wire    [`REG_ADDR_BUS]     i_execute_w_reg_addr,
    input   wire    [`REG_BUS]          i_execute_w_reg_data,

    // deal RAW data hazard in Memory stage
    input   wire                        i_memory_w_reg_en,
    input   wire [`REG_ADDR_BUS]        i_memory_w_reg_addr,
    input   wire [`REG_BUS]             i_memory_w_reg_data,

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

    //! 首先按照指令码opcode进行判断
    //!     a. 如果是SPECIAL类型
    //!         1. 先判断op1，如果op1为0，那么就可以根据功能吗funct进行判断
    //!         2. 否则，是无效指令
    //!     b. 如果不是SPECIAL类型
    //!         1. 那么就是立即数类型
    //! 如果指令码opcode是0
    //!     a. 判断op3，就能够得出指令
    wire [5:0] op   = i_fetch_inst[31:26];      // opcode 指令码
    wire [4:0] op1  = i_fetch_inst[10:6];
    wire [5:0] op2  = i_fetch_inst[5:0];        // funct 功能码
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
            imm                     <= `ZERO_WORD;

            // to configure each instruction individually
            //! 首先按照指令码opcode进行判断
            //!     a. 如果是SPECIAL类型
            //!         1. 先判断op1，如果op1为0，那么就可以根据功能吗funct进行判断
            //!         2. 否则，是无效指令
            //!     b. 如果不是SPECIAL类型
            //!         1. 那么就是立即数类型
            //! 如果指令码opcode是0
            //!     a. 判断op3，就能够得出指令
            case (op)
                `EXE_SPECIAL_INST: begin        // 首先判断SPECIAL码
                    case (op1)
                        5'b00_000: begin        // 如果op1 = 0，就可用funct去判断
                            case (op2)
                                `EXE_OR: begin
                                    o_execute_w_reg_en  <= `WRITE_ENABLE;
                                    o_execute_alu_op    <= `EXE_OR_OP; 
                                    o_execute_alu_sel   <= `EXE_RES_LOGIC;
                                    o_regfile_r_reg_en1 <= `READ_ENABLE;
                                    o_regfile_r_reg_en2 <= `READ_ENABLE;
                                    inst_valid          <= `INST_VALID;
                                end
                                `EXE_AND: begin
                                    o_execute_w_reg_en  <= `WRITE_ENABLE;
                                    o_execute_alu_op    <= `EXE_AND_OP; 
                                    o_execute_alu_sel   <= `EXE_RES_LOGIC;
                                    o_regfile_r_reg_en1 <= `READ_ENABLE;
                                    o_regfile_r_reg_en2 <= `READ_ENABLE;
                                    inst_valid          <= `INST_VALID;
                                end
                                `EXE_XOR: begin
                                    o_execute_w_reg_en  <= `WRITE_ENABLE;
                                    o_execute_alu_op    <= `EXE_XOR_OP; 
                                    o_execute_alu_sel   <= `EXE_RES_LOGIC;
                                    o_regfile_r_reg_en1 <= `READ_ENABLE;
                                    o_regfile_r_reg_en2 <= `READ_ENABLE;
                                    inst_valid          <= `INST_VALID;
                                end
                                `EXE_NOR: begin
                                    o_execute_w_reg_en  <= `WRITE_ENABLE;
                                    o_execute_alu_op    <= `EXE_NOR_OP; 
                                    o_execute_alu_sel   <= `EXE_RES_LOGIC;
                                    o_regfile_r_reg_en1 <= `READ_ENABLE;
                                    o_regfile_r_reg_en2 <= `READ_ENABLE;
                                    inst_valid          <= `INST_VALID;
                                end
                                `EXE_SLLV: begin
                                    o_execute_w_reg_en  <= `WRITE_ENABLE;
                                    o_execute_alu_op    <= `EXE_SLL_OP; 
                                    o_execute_alu_sel   <= `EXE_RES_SHIFT;
                                    o_regfile_r_reg_en1 <= `READ_ENABLE;
                                    o_regfile_r_reg_en2 <= `READ_ENABLE;
                                    inst_valid          <= `INST_VALID;
                                end
                                `EXE_SRLV: begin
                                    o_execute_w_reg_en  <= `WRITE_ENABLE;
                                    o_execute_alu_op    <= `EXE_SRL_OP; 
                                    o_execute_alu_sel   <= `EXE_RES_SHIFT;
                                    o_regfile_r_reg_en1 <= `READ_ENABLE;
                                    o_regfile_r_reg_en2 <= `READ_ENABLE;
                                    inst_valid          <= `INST_VALID;
                                end
                                `EXE_SRAV: begin
                                    o_execute_w_reg_en  <= `WRITE_ENABLE;
                                    o_execute_alu_op    <= `EXE_SRA_OP; 
                                    o_execute_alu_sel   <= `EXE_RES_SHIFT;
                                    o_regfile_r_reg_en1 <= `READ_ENABLE;
                                    o_regfile_r_reg_en2 <= `READ_ENABLE;
                                    inst_valid          <= `INST_VALID;
                                end
                                `EXE_SYNC: begin
                                    o_execute_w_reg_en  <= `WRITE_DISABLE;
                                    o_execute_alu_op    <= `EXE_NOP_OP; 
                                    o_execute_alu_sel   <= `EXE_RES_NOP;
                                    o_regfile_r_reg_en1 <= `READ_DISABLE;
                                    o_regfile_r_reg_en2 <= `READ_ENABLE;
                                    inst_valid          <= `INST_VALID;
                                end
                                default: begin
                                end
                            endcase
                        end
                    default: begin
                    end
                    endcase //! end op1
                end //! end EXE_SPECIAL_INST
                `EXE_ORI: begin
                    o_execute_w_reg_en      <= `WRITE_ENABLE;                   // write enable for rd
                    o_execute_alu_op        <= `EXE_OR_OP;                      // or logic instruction
                    o_execute_alu_sel       <= `EXE_RES_LOGIC;                  // logic instruction
                    o_regfile_r_reg_en1     <= `READ_ENABLE;                    // read enable for rs1
                    o_regfile_r_reg_en2     <= `READ_DISABLE;                   // rs2 for imm, so don't need read enable
                    imm                     <= { 16'h0, i_fetch_inst[15:0] };     // unsigned extend for imm
                    o_execute_w_reg_addr    <= i_fetch_inst[20:16];               // rd's position
                    inst_valid              <= `INST_VALID;                     // valid instruction
                end
                `EXE_ANDI: begin
                    o_execute_w_reg_en      <= `WRITE_ENABLE;                  
                    o_execute_alu_op        <= `EXE_AND_OP;                    
                    o_execute_alu_sel       <= `EXE_RES_LOGIC;                 
                    o_regfile_r_reg_en1     <= `READ_ENABLE;            
                    o_regfile_r_reg_en2     <= `READ_DISABLE;               
                    imm                     <= { 16'h0, i_fetch_inst[15:0] };    
                    o_execute_w_reg_addr    <= i_fetch_inst[20:16];        
                    inst_valid              <= `INST_VALID;                  
                end
                `EXE_XORI: begin
                    o_execute_w_reg_en      <= `WRITE_ENABLE;                  
                    o_execute_alu_op        <= `EXE_XOR_OP;                    
                    o_execute_alu_sel       <= `EXE_RES_LOGIC;                 
                    o_regfile_r_reg_en1     <= `READ_ENABLE;            
                    o_regfile_r_reg_en2     <= `READ_DISABLE;               
                    imm                     <= { 16'h0, i_fetch_inst[15:0] };    
                    o_execute_w_reg_addr    <= i_fetch_inst[20:16];        
                    inst_valid              <= `INST_VALID;                  
                end
                `EXE_LUI: begin
                    o_execute_w_reg_en      <= `WRITE_ENABLE;                  
                    o_execute_alu_op        <= `EXE_OR_OP;                    
                    o_execute_alu_sel       <= `EXE_RES_LOGIC;                 
                    o_regfile_r_reg_en1     <= `READ_ENABLE;            
                    o_regfile_r_reg_en2     <= `READ_DISABLE;               
                    imm                     <= { 16'h0, i_fetch_inst[15:0] };    
                    o_execute_w_reg_addr    <= i_fetch_inst[20:16];        
                    inst_valid              <= `INST_VALID;                  
                end
                `EXE_PREF: begin
                    o_execute_w_reg_en      <= `WRITE_DISABLE;                  
                    o_execute_alu_op        <= `EXE_NOP_OP;                    
                    o_execute_alu_sel       <= `EXE_RES_NOP;                 
                    o_regfile_r_reg_en1     <= `READ_DISABLE;            
                    o_regfile_r_reg_en2     <= `READ_DISABLE;               
                    imm                     <= { 16'h0, i_fetch_inst[15:0] };    
                    o_execute_w_reg_addr    <= i_fetch_inst[20:16];        
                    inst_valid              <= `INST_VALID;                  
                end
                default: begin
                end
            endcase //! end op

            if (i_fetch_inst[31: 21] == 11'b00000000000) begin
                if (op2 == `EXE_SLL) begin
                    o_execute_w_reg_en      <= `WRITE_ENABLE;                  
                    o_execute_alu_op        <= `EXE_SLL_OP;                    
                    o_execute_alu_sel       <= `EXE_RES_SHIFT;                 
                    o_regfile_r_reg_en1     <= `READ_DISABLE;            
                    o_regfile_r_reg_en2     <= `READ_ENABLE;               
                    imm[4:0]                <= i_fetch_inst[10:6];    
                    o_execute_w_reg_addr    <= i_fetch_inst[15:11];        
                    inst_valid              <= `INST_VALID;                  
                end else if (op2 == `EXE_SRL) begin
                    o_execute_w_reg_en      <= `WRITE_ENABLE;                  
                    o_execute_alu_op        <= `EXE_SRL_OP;                    
                    o_execute_alu_sel       <= `EXE_RES_SHIFT;                 
                    o_regfile_r_reg_en1     <= `READ_DISABLE;            
                    o_regfile_r_reg_en2     <= `READ_ENABLE;               
                    imm[4:0]                <= i_fetch_inst[10:6];    
                    o_execute_w_reg_addr    <= i_fetch_inst[15:11];        
                    inst_valid              <= `INST_VALID;            
                end else if (op2 == `EXE_SRA) begin
                    o_execute_w_reg_en      <= `WRITE_ENABLE;                  
                    o_execute_alu_op        <= `EXE_SRA_OP;                    
                    o_execute_alu_sel       <= `EXE_RES_SHIFT;                 
                    o_regfile_r_reg_en1     <= `READ_DISABLE;            
                    o_regfile_r_reg_en2     <= `READ_ENABLE;               
                    imm[4:0]                <= i_fetch_inst[10:6];    
                    o_execute_w_reg_addr    <= i_fetch_inst[15:11];        
                    inst_valid              <= `INST_VALID;                
                end
            end
        end
    end


    // if rst is enable, rs1 and rs2 are all be reset
    //! if rs1(or rs2) is enable, read rs1(or rs2)'s data
    //! if rs1(or rs2) is disable, it repretend rs1(or rs2) is imme
    //! all other cases are assigned a value of 0
    //! 新增：对于Execute和Memory阶段被依赖的结果，需要forwarding
    //!     如果和目的寄存器一样，且写使能和读使能导通，就会发生RAW
    always @(*) begin
        if (rst == `RST_ENABLE) begin
            o_execute_reg_data1 <= `ZERO_WORD;
        end else if ((o_regfile_r_reg_en1 == `READ_ENABLE) &&
            (i_execute_w_reg_en == `WRITE_ENABLE) &&
            (i_execute_w_reg_addr == o_regfile_r_reg_addr1)) begin
            o_execute_reg_data1 <= i_execute_w_reg_data;
        end else if ((o_regfile_r_reg_en1 == `READ_ENABLE) &&
            (i_memory_w_reg_en == `WRITE_ENABLE) &&
            (i_memory_w_reg_addr == o_regfile_r_reg_addr1)) begin
            o_execute_reg_data1 <= i_execute_w_reg_data;
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
        end else if ((o_regfile_r_reg_en2 == `READ_ENABLE) &&
            (i_execute_w_reg_en == `WRITE_ENABLE) &&
            (i_execute_w_reg_addr == o_regfile_r_reg_addr2)) begin
            o_execute_reg_data2 <= i_execute_w_reg_data;
        end else if ((o_regfile_r_reg_en2 == `READ_ENABLE) &&
            (i_memory_w_reg_en == `WRITE_ENABLE) &&
            (i_memory_w_reg_addr == o_regfile_r_reg_addr2)) begin
            o_execute_reg_data2 <= i_execute_w_reg_data;
        end else if(o_regfile_r_reg_en2 == `READ_ENABLE) begin
            o_execute_reg_data2 <= i_regfile_reg_data2;
        end else if(o_regfile_r_reg_en2 == `READ_DISABLE) begin
            o_execute_reg_data2 <= imm;
        end else begin
            o_execute_reg_data2 <= `ZERO_WORD;
        end
    end
endmodule

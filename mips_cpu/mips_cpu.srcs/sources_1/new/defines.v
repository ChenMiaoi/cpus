`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/16/2024 02:06:49 PM
// Design Name: 
// Module Name: defines
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

// ======================   Global Macro Functions  ======================
`define RST_ENABLE              1'b1                    // enable reset signal
`define RST_DISABLE             1'b0                    // disable reset signal

`define ZERO_WORD               32'h0000_0000           // 0 for 32-bits

`define WRITE_ENABLE            1'b1                    // enable write
`define WRITE_DISABLE           1'b0                    // disable write
`define READ_ENABLE             1'b1                    // enable read
`define READ_DISABLE            1'b0                    // disable read

`define ALU_OP_BUS              7:0                     // ALU operator width
`define ALU_SEL_BUS             2:0                     // TODO

`define INST_VALID              1'b1                    // valid instruction
`define INST_INVALID            1'b0                    // invalid instruction

`define TRUE_V                  1'b1                    // TRUE for logic
`define FALSE_V                 1'b0                    // FALSE for logic

`define CHIP_ENABLE             1'b1                    // enable chip
`define CHIP_DISABLE            1'b0                    // disable 

`define STOP_ENABLE             1'b1
`define STOP_DISABLE            1'b0

// ======================   Macros for Specific Instructions  ======================
/* instruction: ORI */ 
`define EXE_AND                 6'b100_100              // funct for and
`define EXE_OR                  6'b100_101              // funct for or
`define EXE_XOR                 6'b100_110              // funct for xor
`define EXE_NOR                 6'b100_111              // funct for nor
`define EXE_ANDI                6'b001_100              // opcode for andi
`define EXE_ORI                 6'b001_101              // opcode for ori
`define EXE_XORI                6'b001_110              // opcode for xori
`define EXE_LUI                 6'b001_111              // opcode for lui

`define EXE_SLL                 6'b000_000              // funct for sll
`define EXE_SLLV                6'b000_100              // funct for sllv
`define EXE_SRL                 6'b000_010              // funct for srl
`define EXE_SRLV                6'b000_110              // funct for srlv
`define EXE_SRA                 6'b000_011              // funct for sra
`define EXE_SRAV                6'b000_111              // funct for srav

`define EXE_MOVZ                6'b001_010
`define EXE_MOVN                6'b001_011
`define EXE_MFHI                6'b010_000
`define EXE_MTHI                6'b010_001
`define EXE_MFLO                6'b010_010
`define EXE_MTLO                6'b010_011

`define EXE_SLT                 6'b101_010
`define EXE_SLTU                6'b101_011
`define EXE_SLTI                6'b001_010
`define EXE_SLTIU               6'b001_011   
`define EXE_ADD                 6'b100_000
`define EXE_ADDU                6'b100_001
`define EXE_SUB                 6'b100_010
`define EXE_SUBU                6'b100_011
`define EXE_ADDI                6'b001_000
`define EXE_ADDIU               6'b001_001
`define EXE_CLZ                 6'b100_000
`define EXE_CLO                 6'b100_001

`define EXE_MUL                 6'b000_010
`define EXE_MULT                6'b011_000
`define EXE_MULTU               6'b011_001
`define EXE_MADD                6'b000_000
`define EXE_MADDU               6'b000_001
`define EXE_MSUB                6'b000_100
`define EXE_MSUBU               6'b000_101

`define EXE_DIV                 6'b011_010
`define EXE_DIVU                6'b011_011

`define EXE_SYNC                6'b001_111              // funct for sync
`define EXE_PREF                6'b110_011              // opcode for pref

`define EXE_SPECIAL_INST        6'b000_000              // opcode for SPECIAL
`define EXE_REGIMM_INST         6'b000_001
`define EXE_SPECIAL2_INST       6'b011_100

/* instruction: NOP */ 
`define EXE_NOP                 6'b000_000              // opcode for nop
`define SSNOP                   32'b00000000_00000000_00000000_01000000

/* ALU op code: */ 
`define EXE_AND_OP              8'b0010_0100
`define EXE_OR_OP               8'b0010_0101
`define EXE_XOR_OP              8'b0010_0110
`define EXE_NOR_OP              8'b0010_0111
`define EXE_ANDI_OP             8'b0101_1001
`define EXE_ORI_OP              8'b0101_1010
`define EXE_XORI_OP             8'b0101_1011
`define EXE_LUI_OP              8'b0101_1100   

`define EXE_SLL_OP              8'b0111_1100
`define EXE_SLLV_OP             8'b0000_0100
`define EXE_SRL_OP              8'b0000_0010
`define EXE_SRLV_OP             8'b0000_0110
`define EXE_SRA_OP              8'b0000_0011
`define EXE_SRAV_OP             8'b0000_0111
`define EXE_NOP_OP              8'b0000_0000            // ALU opcode for nop

`define EXE_MOVZ_OP             8'b0000_1010
`define EXE_MOVN_OP             8'b0000_1011
`define EXE_MFHI_OP             8'b0001_0000
`define EXE_MTHI_OP             8'b0001_0001
`define EXE_MFLO_OP             8'b0001_0010
`define EXE_MTLO_OP             8'b0001_0011

`define EXE_SLT_OP              8'b0010_1010
`define EXE_SLTU_OP             8'b0010_1011
`define EXE_SLTI_OP             8'b0101_0111
`define EXE_SLTIU_OP            8'b0101_1000   
`define EXE_ADD_OP              8'b0010_0000
`define EXE_ADDU_OP             8'b0010_0001
`define EXE_SUB_OP              8'b0010_0010
`define EXE_SUBU_OP             8'b0010_0011
`define EXE_ADDI_OP             8'b0101_0101
`define EXE_ADDIU_OP            8'b0101_0110
`define EXE_CLZ_OP              8'b1011_0000
`define EXE_CLO_OP              8'b1011_0001

`define EXE_MUL_OP              8'b1010_1001
`define EXE_MULT_OP             8'b0001_1000
`define EXE_MULTU_OP            8'b0001_1001
`define EXE_MADD_OP             8'b1010_0110
`define EXE_MADDU_OP            8'b1010_1000
`define EXE_MSUB_OP             8'b1010_1010
`define EXE_MSUBU_OP            8'b1010_1011

`define EXE_DIV_OP              8'b00011010
`define EXE_DIVU_OP             8'b00011011

/* ALU funct: */ 
`define EXE_RES_LOGIC           3'b001                  // TODO 
`define EXE_RES_SHIFT           3'b010
`define EXE_RES_MOVE            3'b011	
`define EXE_RES_ARITHMETIC      3'b100	
`define EXE_RES_MUL             3'b101
`define EXE_RES_NOP             3'b000                  // TODO

// ======================   Macros for Div  ======================
`define DIV_FREE                2'b00
`define DIV_BY_ZERO             2'b01
`define DIV_ON                  2'b10
`define DIV_END                 2'b11
`define DIV_RESULT_READY_ENABLE 1'b1
`define DIV_RESULT_READY_DISABLE 1'b0
`define DIV_START               1'b1
`define DIV_STOP                1'b0  

// ======================   Macros for Instruction Memory  ======================
`define INST_ADDR_BUS           31:0                    // the address bus width of ROM
`define INST_BUS                31:0                    // the data bus width of ROM
`define INST_MEM_NUM            131071                  // the real size for ROM, 128KN
`define INST_MEM_NUM_LOG        17                      // the real used address width for ROM

// ======================   Macros for Generical Register  ======================
`define REG_ADDR_BUS            4:0                     // for 32 registers
`define REG_BUS                 31:0                    // for register's bits
`define REG_WIDTH               32                      // generical register's width
`define DOUBLE_REG_WIDTH        64                      // dual the generical
`define DOUBLE_REG_BUS          63:0                    // dual the generical's bits
`define REG_NUM                 32                      // generical registers' size
`define REG_NUM_LOG             5                       // the real used address width for reg
`define NOP_REG_ADDR            5'b00000 

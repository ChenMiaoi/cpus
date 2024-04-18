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
`define CHIP_DISABLE            1'b0                    // disable chip

// ======================   Macros for Specific Instructions  ======================
/* instruction: ORI */ 
`define EXE_ORI                 6'b001_101              // opcode for ori
/* instruction: NOP */ 
`define EXE_NOP                 6'b000_000              // opcode for nop

/* ALU op code: */ 
`define EXE_OR_OP               8'b0010_0101            // ALU opcode for or
`define EXE_NOP_OP              8'b0000_0000            // ALU opcode for nop

/* ALU TODO: */ 
`define EXE_RES_LOGIC           3'b001                  // TODO 
`define EXE_RES_NOP             3'b000                  // TODO

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

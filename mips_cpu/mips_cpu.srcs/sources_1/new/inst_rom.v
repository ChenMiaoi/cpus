`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/17/2024 11:10:23 PM
// Design Name: 
// Module Name: inst_rom
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

module inst_rom(
    input   wire                        i_pc_en,
    input   wire    [`INST_ADDR_BUS]    i_pc_addr,
    output  reg     [`INST_BUS]         o_fetch_inst
    );

    reg [`INST_BUS] inst_mem[0:`INST_MEM_NUM - 1];

    initial $readmemh("ori_instructions.mem", inst_mem);

    always @(*) begin
        if (i_pc_en == `CHIP_DISABLE) begin
            o_fetch_inst <= `ZERO_WORD;
        end else begin
            o_fetch_inst <= inst_mem[i_pc_addr[`INST_MEM_NUM_LOG + 1:2]];
        end
    end
endmodule

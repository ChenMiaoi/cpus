`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/16/2024 02:10:12 PM
// Design Name: 
// Module Name: pc
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

module pc(
    input   wire                        rst,        // reset signal
    input   wire                        clk,        // clock signal
    output  reg                         inst_en,    // instruction memory enable signal
    output  reg     [`INST_ADDR_BUS]    pc_addr     // need to get the address of pc 
    );

    always @(posedge clk) begin
        if (rst == `RST_ENABLE) begin
            inst_en <= `CHIP_DISABLE;           // instruction memory should disable when reset enable
        end else begin
            inst_en <= `CHIP_ENABLE;            // done the reset, inst mem can be enable
        end
    end

    always @(posedge clk) begin
        if (inst_en == `CHIP_DISABLE) begin
            pc_addr <= `ZERO_WORD;              // if inst_en is disable, pc_addr can't be use
        end else begin
            pc_addr <= pc_addr + 4'h4;          // pc_addr add 4 per clock time
        end
    end
endmodule

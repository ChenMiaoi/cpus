`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/17/2024 11:25:08 PM
// Design Name: 
// Module Name: mips_sopc_tb
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
`include "../../sources_1/new/defines.v" 

module mips_sopc_tb();
    reg     clk_50;
    reg     rst;

    initial begin
        clk_50 = 1'b0;
        forever #10 begin
            clk_50 = !clk_50;
        end
    end

    initial begin
        rst = `RST_ENABLE;
        #195 rst = `RST_DISABLE;
        #1000 $stop;
    end

    mips_sopc u_mips_sopc(
        .clk 	( clk_50  ),
        .rst 	( rst  )
    );
    
endmodule

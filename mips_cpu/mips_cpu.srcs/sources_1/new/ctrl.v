`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/25/2024 06:23:56 PM
// Design Name: 
// Module Name: ctrl
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

module ctrl(
    input rst,
    
    input   wire        i_inst_decode_stall_req,
    input   wire        i_execute_stall_req,
    
    //! stall[0]表示取指地址PC是否保持不变
    //! stall[1]表示流水线取指阶段是否保持不变
    //! stall[2]表示流水线译码阶段是否保持不变
    //! stall[3]表示流水线执行阶段是否保持不变
    //! stall[4]表示流水线访存阶段是否保持不变
    //! stall[5]表示流水线回写阶段是否保持不变
    output  reg [5:0]   o_stall_req
    );

    always @(*) begin
        if (rst == `RST_ENABLE) begin
            o_stall_req <= 6'b000_000;
        end else if (i_inst_decode_stall_req == `STOP_ENABLE) begin
            //! 译码阶段请求暂停时，需要对取指、译码阶段暂停；而其余阶段不变
            o_stall_req <= 6'b000_111;
        end else if (i_execute_stall_req == `STOP_ENABLE) begin
            //! 执行阶段请求暂停时，需要对取指、译码、执行阶段暂停；而其余阶段不变
            o_stall_req <= 6'b001_111;
        end else begin
            o_stall_req <= 6'b000_000;
        end
    end
endmodule

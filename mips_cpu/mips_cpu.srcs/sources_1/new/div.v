`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/28/2024 08:30:01 AM
// Design Name: 
// Module Name: div
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

module div(
    input wire              rst,
    input wire              clk,
    input wire              i_signed_div_en,
    input wire  [31:0]      i_opdata1,
    input wire  [31:0]      i_opdata2,
    input wire              i_start_en,
    input wire              i_annul_en,

    output reg  [63:0]      o_result,
    output reg              o_ready_en
    );

    wire [31:0]     div_temp;
    reg  [5:0]      cnt;
    reg  [64:0]     dividend;
    reg  [1:0]      state;
    reg  [31:0]     divisor;
    reg  [31:0]     temp_opdata1;
    reg  [31:0]     temp_opdata2;

    assign div_temp = { 1'b0 - dividend[63:32] } - { 1'b0, divisor };

    always @(*) begin
        if (rst == `RST_ENABLE) begin
            state       <= `DIV_FREE;
            o_ready_en  <= `DIV_RESULT_READY_DISABLE;
            o_result    <= { `ZERO_WORD, `ZERO_WORD };
        end else begin
            case (state)
                `DIV_FREE: begin
                    if (i_start_en == `DIV_START && i_annul_en == 1'b0) begin
                        if (i_opdata1 == `ZERO_WORD) begin
                            state   <= `DIV_BY_ZERO; 
                        end else begin
                            state   <= `DIV_ON;
                            cnt     <= 6'b000_000;
                            if (i_signed_div_en == 1'b1 && i_opdata1[31] == 1'b1) begin
                                temp_opdata1 <= ~i_opdata1 + 1; 
                            end else begin
                                temp_opdata1 <= i_opdata1;
                            end
                            if (i_signed_div_en == 1'b1 && i_opdata2[31] == 1'b1) begin
                                temp_opdata2 <= ~i_opdata2 + 1; 
                            end else begin
                                temp_opdata2 <= i_opdata2;
                            end
                            dividend        <= { `ZERO_WORD, `ZERO_WORD };
                            dividend[32:1]  <= temp_opdata1;
                            divisor         <= temp_opdata2;
                        end
                    end else begin
                        o_ready_en  <= `DIV_RESULT_READY_DISABLE;
                        o_result    <= { `ZERO_WORD, `ZERO_WORD }; 
                    end
                end
                `DIV_BY_ZERO: begin
                    dividend    <= { `ZERO_WORD, `ZERO_WORD };
                    state       <= `DIV_END;
                end
                `DIV_ON: begin
                    if (i_annul_en == 1'b0) begin
                        if (cnt != 6'b100_000) begin
                            if (div_temp[32] == 1'b1) begin
                                dividend    <= { dividend[63:0], 1'b0 }; 
                            end else begin
                                dividend    <= { div_temp[31:0], dividend[31:0], 1'b1 }; 
                            end
                            cnt <= cnt + 1;
                        end else begin
                            if ((i_signed_div_en == 1'b1) && (i_opdata1[31] ^ i_opdata2[31] == 1'b1)) begin
                                dividend[31:0]  <= ~dividend[31:0] + 1;
                            end
                            if ((i_signed_div_en == 1'b1) && (i_opdata1[31] ^ dividend[64] == 1'b1)) begin
                                dividend[64:33] <= ~dividend[64:33] + 1; 
                            end
                            state   <= `DIV_END;
                            cnt     <= 6'b000_000;
                        end
                    end else begin
                        state <= `DIV_FREE; 
                    end
                end
                `DIV_END: begin
                    o_result    <= { dividend[64:33], dividend[31:0] };
                    o_ready_en  <= `DIV_RESULT_READY_ENABLE;
                    if (i_start_en == `DIV_STOP) begin
                        state       <= `DIV_FREE;
                        o_ready_en  <= `DIV_RESULT_READY_DISABLE; 
                        o_result    <= { `ZERO_WORD, `ZERO_WORD };
                    end
                end
            endcase 
        end
    end
endmodule

`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/16/2024 03:07:59 PM
// Design Name: 
// Module Name: regfile
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

module regfile(
    input   wire                        rst,
    input   wire                        clk,
    input   wire    [`REG_ADDR_BUS]     i_w_reg_addr,     // rd's addr
    input   wire    [`REG_BUS]          i_w_reg_data,     // rd's data
    input   wire    [`REG_ADDR_BUS]     i_r_reg_addr1,    // rs1's addr
    input   wire    [`REG_ADDR_BUS]     i_r_reg_addr2,    // rs2's addr
    input   wire                        i_w_reg_en,       // write rd enable
    input   wire                        i_r_reg_en1,      // read rs1 enable
    input   wire                        i_r_reg_en2,      // read rs2 enable
    output  reg     [`REG_BUS]          o_r_reg_data1,    // read rs1's data
    output  reg     [`REG_BUS]          o_r_reg_data2     // read rs2's data
    );

    reg [`REG_BUS] regs[0: `REG_NUM - 1];

    // if w_en is enable and the rd is not $0 reg, we can write data into this rd
    //! write opertion is sequntial logic and happen on clock rising edge
    always @(posedge clk) begin
        if (rst == `RST_DISABLE) begin
            if ((i_w_reg_en == `WRITE_ENABLE) && (i_w_reg_addr != `REG_NUM_LOG'h0)) begin
                regs[i_w_reg_addr] <= i_w_reg_data;
            end
        end
    end

    // if rst is enable, the rs1's and rs2' data are both reset to 0
    // if rs1 or rs2 want read $0, and the $0 is always 0, the rs1's or rs2's data will be 0
    // if rs1(or rs2) = rd, directly the value to be written is the output of rs1(or rs2)
    // if rs1 or rs2 just read, get the corresponding value in regs as output of rs1 or rs2
    // if rs1 or rs2 can't read, output 0 to present
    //! read opertion is combination logic, 
    //! as soon as the corresponding register address changes, the value of the register is given immediately
    always @(*) begin
        if (rst == `RST_ENABLE) begin
            o_r_reg_data1 <= `ZERO_WORD;
        end else if(i_r_reg_addr1 == `REG_NUM_LOG'h0) begin
            o_r_reg_data1 <= `ZERO_WORD;
        end else if((i_r_reg_addr1 == i_w_reg_addr) && 
            (i_w_reg_en == `WRITE_ENABLE)     && 
            (i_r_reg_en1 == `READ_ENABLE)) begin
            o_r_reg_data1 <= i_w_reg_data;
        end else if(i_r_reg_en1 == `READ_ENABLE) begin
            o_r_reg_data1 <= regs[i_r_reg_addr1];
        end else begin
            o_r_reg_data1 <= `ZERO_WORD;
        end
    end

    always @(*) begin
        if (rst == `RST_ENABLE) begin
            o_r_reg_data2 <= `ZERO_WORD;
        end else if(i_r_reg_addr2 == `REG_NUM_LOG'h0) begin
            o_r_reg_data2 <= `ZERO_WORD;
        end else if((i_r_reg_addr2 == i_w_reg_addr) && 
            (i_w_reg_en == `WRITE_ENABLE)     && 
            (i_r_reg_en1 == `READ_ENABLE)) begin
            o_r_reg_data2 <= i_w_reg_data;
        end else if(i_r_reg_en2 == `READ_ENABLE) begin
            o_r_reg_data2 <= regs[i_r_reg_addr2];
        end else begin
            o_r_reg_data2 <= `ZERO_WORD;
        end
    end
endmodule

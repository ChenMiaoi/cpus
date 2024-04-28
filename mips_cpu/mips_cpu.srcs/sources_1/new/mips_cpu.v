`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/17/2024 10:03:07 PM
// Design Name: 
// Module Name: mips_cpu
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

module mips_cpu(
    input   wire                rst,
    input   wire                clk,
    input   wire    [`REG_BUS]  i_rom_data,
    output  wire                o_rom_en,
    output  wire    [`REG_BUS]  o_rom_addr
    );

    // for inst_fetch and inst decode
    wire [`INST_ADDR_BUS]   pc_addr;
    wire [`INST_ADDR_BUS]   i_inst_decode_pc;
    wire [`INST_BUS]        i_inst_decode_inst;

    // for inst decode output and inst decode with execute input
    wire [`ALU_OP_BUS]      o_inst_decode_alu_op;
    wire [`ALU_SEL_BUS]     o_inst_decode_alu_sel;
    wire [`REG_BUS]         o_inst_decode_reg1;
    wire [`REG_BUS]         o_inst_decode_reg2;
    wire                    o_inst_decode_reg_en;
    wire [`REG_ADDR_BUS]    o_inst_decode_reg_addr;

    // for inst decode with execute output and execute input
    wire [`ALU_OP_BUS]      i_execute_alu_op;
    wire [`ALU_SEL_BUS]     i_execute_alu_sel;
    wire [`REG_BUS]         i_execute_reg1;
    wire [`REG_BUS]         i_execute_reg2;
    wire                    i_execute_w_reg_en;
    wire [`REG_ADDR_BUS]    i_execute_w_reg_addr;

    // for execute output and execute with memory input
    wire                    o_execute_w_reg_en;
    wire [`REG_ADDR_BUS]    o_execute_w_reg_addr;
    wire [`REG_BUS]         o_execute_w_reg_data;
    //! 新增：对HILO模块的输出
    wire                    o_execute_w_reg_hilo_en;
    wire [`REG_BUS]         o_execute_w_reg_hi_data;
    wire [`REG_BUS]         o_execute_w_reg_lo_data;

    // for execute with memory output and memory input
    wire                    i_memory_w_reg_en;
    wire [`REG_ADDR_BUS]    i_memory_w_reg_addr;
    wire [`REG_BUS]         i_memory_w_reg_data;
    //! 新增：对HILO模块的输入
    wire                    i_memory_w_reg_hilo_en;
    wire [`REG_BUS]         i_memory_w_reg_hi_data;
    wire [`REG_BUS]         i_memory_w_reg_lo_data;

    // for memory output and memory wirte back input
    wire                    o_memory_w_reg_en;
    wire [`REG_ADDR_BUS]    o_memory_w_reg_addr;
    wire [`REG_BUS]         o_memory_w_reg_data;
    //! 新增：对HILO模块的输出
    wire                    o_memory_w_reg_hilo_en;
    wire [`REG_BUS]         o_memory_w_reg_hi_data;
    wire [`REG_BUS]         o_memory_w_reg_lo_data;

    // for memory write back output and write back input
    wire                    i_write_back_w_reg_en;
    wire [`REG_ADDR_BUS]    i_write_back_w_reg_addr;
    wire [`REG_BUS]         i_write_back_w_reg_data;
    //! 新增：对HILO模块的输入
    wire                    i_write_back_w_reg_hilo_en;
    wire [`REG_BUS]         i_write_back_w_reg_hi_data;
    wire [`REG_BUS]         i_write_back_w_reg_lo_data;

    // for inst decode and regfile
    wire                    read_reg1_en;
    wire                    read_reg2_en;
    wire [`REG_BUS]         read_reg1_data;
    wire [`REG_BUS]         read_reg2_data;
    wire [`REG_ADDR_BUS]    read_reg1_addr;
    wire [`REG_ADDR_BUS]    read_reg2_addr;

    //! 新增：HILO模块
    wire [`REG_BUS]         read_hi_data;
    wire [`REG_BUS]         read_lo_data;

    //! 新增：CTRL模块，用于多周期的MADD等指令
    wire [`DOUBLE_REG_BUS]  o_hilo_temp;
    wire [1:0]              o_clk_cnt;
    wire [`DOUBLE_REG_BUS]  i_hilo_temp;
    wire [1:0]              i_clk_cnt;

    wire [5:0]              stall_req;
    wire                    o_inst_decode_stall_req;
    wire                    o_execute_stall_req;

    //! 新增：DIV模块
    wire                    div_ready_en;
    wire                    div_start_en;
	wire                    div_annul_en;
	wire                    signed_div_en;
    wire [`REG_BUS]         div_opdata1;
    wire [`REG_BUS]         div_opdata2;
    wire [`DOUBLE_REG_BUS]  div_result;

    // outports wire
    // wire        	inst_en;
    // wire [31:0] 	pc_addr;
    
    pc pc_reg0(
        .rst     	( rst       ),
        .clk     	( clk       ),
        //! 新增：CTRL模块信号输入
        .i_stall_req( stall_req ),
        .inst_en 	( o_rom_en  ),
        .pc_addr 	( pc_addr   )
    );
    
    assign o_rom_addr = pc_addr;

    inst_fetch if_id0(
        .clk                    ( clk           ),
        .rst                    ( rst           ),
        //! 新增：CTRL模块信号输入
        .i_stall_req            ( stall_req     ),
        .i_rom_pc               ( pc_addr       ),
        .i_rom_inst             ( i_rom_data    ),
        .o_inst_decode_pc       ( i_inst_decode_pc  ),
        .o_inst_decode_inst     ( i_inst_decode_inst)
    );

    inst_decode id0(
        .rst(rst),  .i_fetch_pc(i_inst_decode_pc),      .i_fetch_inst(i_inst_decode_inst),

        // form regfile output
        .i_regfile_reg_data1(read_reg1_data),           .i_regfile_reg_data2(read_reg2_data),

        //! 新增：对于Execute和Memory阶段的RAW处理
        .i_execute_w_reg_en(o_execute_w_reg_en),        .i_execute_w_reg_addr(o_execute_w_reg_addr),
        .i_execute_w_reg_data(o_execute_w_reg_data),

        .i_memory_w_reg_en(o_memory_w_reg_en),          .i_memory_w_reg_addr(o_memory_w_reg_addr),
        .i_memory_w_reg_data(o_memory_w_reg_data),
        
        // send to regfile input
        .o_regfile_r_reg_en1(read_reg1_en),             .o_regfile_r_reg_en2(read_reg2_en),
        .o_regfile_r_reg_addr1(read_reg1_addr),         .o_regfile_r_reg_addr2(read_reg2_addr),

        // send to inst_decode with execute
        .o_execute_alu_op(o_inst_decode_alu_op),        .o_execute_alu_sel(o_inst_decode_alu_sel),
        .o_execute_reg_data1(o_inst_decode_reg1),       .o_execute_reg_data2(o_inst_decode_reg2),
        .o_execute_w_reg_en(o_inst_decode_reg_en),      .o_execute_w_reg_addr(o_inst_decode_reg_addr),

        //! 新增：CTRL信号输出
        .o_stall_req(o_inst_decode_stall_req)
    );

    regfile regfile0(
        .clk(clk),                                      .rst(rst),
        .i_w_reg_en(i_write_back_w_reg_en),             .i_w_reg_addr(i_write_back_w_reg_addr),
        .i_w_reg_data(i_write_back_w_reg_data),

        .i_r_reg_en1(read_reg1_en),                     .i_r_reg_addr1(read_reg1_addr), 
        .o_r_reg_data1(read_reg1_data),
        
        .i_r_reg_en2(read_reg2_en),                     .i_r_reg_addr2(read_reg2_addr), 
        .o_r_reg_data2(read_reg2_data)
    );

    inst_decode_execute id_ex0(
        .clk(clk),                              .rst(rst),

        //! 新增：CTRL信号输入
        .i_stall_req(stall_req),

        // from inst decode output
        .i_inst_decode_alu_op(o_inst_decode_alu_op),        .i_inst_decode_alu_sel(o_inst_decode_alu_sel),
        .i_inst_decode_reg_data1(o_inst_decode_reg1),       .i_inst_decode_reg_data2(o_inst_decode_reg2),
        .i_inst_decode_w_reg_en(o_inst_decode_reg_en),      .i_inst_decode_w_reg_addr(o_inst_decode_reg_addr),

        // send to execute
        .o_execute_alu_op(i_execute_alu_op),                .o_execute_alu_sel(i_execute_alu_sel),
        .o_execute_reg_data1(i_execute_reg1),               .o_execute_reg_data2(i_execute_reg2),
        .o_execute_w_reg_en(i_execute_w_reg_en),            .o_execute_w_reg_addr(i_execute_w_reg_addr)
    );

    execute ex0(
        .rst(rst),

        // from inst_decode_execute output
        .i_inst_decode_alu_op(i_execute_alu_op),        .i_inst_decode_alu_sel(i_execute_alu_sel),
        .i_inst_decode_reg_data1(i_execute_reg1),       .i_inst_decode_reg_data2(i_execute_reg2),
        .i_inst_decode_w_reg_en(i_execute_w_reg_en),    .i_inst_decode_w_reg_addr(i_execute_w_reg_addr),

        //! 新增：HILO
        .i_hilo_reg_hi_data(read_hi_data),              .i_hilo_reg_lo_data(read_lo_data),

        //! 新增：针对于MADD类型的处理
        .i_hilo_temp(i_hilo_temp),                      .i_clk_cnt(i_clk_cnt),

        .i_mem_w_reg_hilo_en(i_memory_w_reg_hilo_en), 
        .i_mem_w_reg_hi_data(i_memory_w_reg_hi_data),   .i_mem_w_reg_lo_data(i_memory_w_reg_lo_data),

        .i_write_back_w_reg_hilo_en(),
        .i_write_back_w_reg_hi_data(),                  .i_write_back_w_reg_lo_data(),

        //! 新增:DIV模块处理
        .i_div_ready_en(div_ready_en),                  .i_div_result(div_result),

        // send to execute_memory input
        .o_w_reg_en(o_execute_w_reg_en),                .o_w_reg_addr(o_execute_w_reg_addr),
        .o_w_reg_data(o_execute_w_reg_data),

        //! 新增：HILO
        .o_w_reg_hilo_en(o_execute_w_reg_hilo_en),
        .o_w_reg_hi_data(o_execute_w_reg_hi_data),      .o_w_reg_lo_data(o_execute_w_reg_lo_data),

        //! 新增：CTRL和针对于MADD类型的处理
        .o_hilo_temp(o_hilo_temp),                      .o_clk_cnt(o_clk_cnt),
        .o_stall_req(o_execute_stall_req),

        //! 新增：DIV模块输出
        .o_signed_div_en(signed_div_en),                .o_div_start_en(div_start_en),
        .o_div_opdata1(div_opdata1),                    .o_div_opdata2(div_opdata2)
    );

    execute_memory ex_mem0(
        .clk(clk),                                      .rst(rst),

        // from execute output
        .i_execute_w_reg_en(o_execute_w_reg_en),        .i_execute_w_reg_addr(o_execute_w_reg_addr),
        .i_execute_w_reg_data(o_execute_w_reg_data),

        //! 新增：CTRL和针对于MADD类型的处理
        .i_hilo_temp(o_hilo_temp),                      .i_clk_cnt(o_clk_cnt),
        .i_stall_req(stall_req),

        //! 新增：HILO
        .i_execute_w_reg_hilo_en(o_execute_w_reg_hilo_en),
        .i_execute_w_reg_hi_data(o_execute_w_reg_hi_data),  .i_execute_w_reg_lo_data(o_execute_w_reg_lo_data),

        // send to memory
        .o_memory_w_reg_en(i_memory_w_reg_en),              .o_memory_w_reg_addr(i_memory_w_reg_addr),
        .o_memory_w_reg_data(i_memory_w_reg_data),

        //! 新增：HILO
        .o_memory_w_reg_hilo_en(i_memory_w_reg_hilo_en),
        .o_memory_w_reg_hi_data(i_memory_w_reg_hi_data),    .o_memory_w_reg_lo_data(i_memory_w_reg_lo_data),

        //! 新增：针对于MADD类型的处理
        .o_hilo_temp(i_hilo_temp),                          .o_clk_cnt(i_clk_cnt)
    );

    memory mem0(
        .rst(rst),

        // from execute_memory output
        .i_execute_w_reg_en(i_memory_w_reg_en),             .i_execute_w_reg_addr(i_memory_w_reg_addr),
        .i_execute_w_reg_data(i_memory_w_reg_data), 

        //! 新增：HILO
        .i_execute_w_reg_hilo_en(i_memory_w_reg_hilo_en), 
        .i_execute_w_reg_hi_data(i_memory_w_reg_hi_data),   .i_execute_w_reg_lo_data(i_memory_w_reg_lo_data),

        // sent to memmory_write_back
        .o_write_back_w_reg_en(o_memory_w_reg_en),          .o_write_back_w_reg_addr(o_memory_w_reg_addr),
        .o_write_back_w_reg_data(o_memory_w_reg_data),

        //! 新增：HILO
        .o_write_back_w_reg_hilo_en(o_memory_w_reg_hilo_en),
        .o_write_back_w_reg_hi_data(o_memory_w_reg_hi_data), .o_write_back_w_reg_lo_data(o_memory_w_reg_lo_data)
    );

    memory_write_back mem_wb0(
        .clk(clk), .rst(rst),

        // from memory output
        .i_memory_w_reg_en(o_memory_w_reg_en),              .i_memory_w_reg_addr(o_memory_w_reg_addr),
        .i_memory_w_reg_data(o_memory_w_reg_data),

        //! 新增：HILO
        .i_memory_w_reg_hilo_en(o_memory_w_reg_hilo_en), 
        .i_memory_w_reg_hi_data(o_memory_w_reg_hi_data),    .i_memory_w_reg_lo_data(o_memory_w_reg_lo_data),

        // sent to write back
        .o_regfile_w_reg_en(i_write_back_w_reg_en),         .o_regfile_w_reg_addr(i_write_back_w_reg_addr),
        .o_regfile_w_reg_data(i_write_back_w_reg_data),
        
        //! 新增：HILO
        .o_hilo_w_reg_hilo_en(i_write_back_w_reg_hilo_en),
        .o_hilo_w_reg_hi_data(i_write_back_w_reg_hi_data),  .o_hilo_w_reg_lo_data(i_write_back_w_reg_lo_data)
    );

    //! 新增HILO模块
    hilo_reg hilo_reg0(
        .clk(clk),                                          .rst(rst),

        //! write
        .i_w_hilo_reg_en(i_write_back_w_reg_hilo_en),
        .i_w_hi_reg_data(i_write_back_w_reg_hi_data),       .i_w_lo_reg_data(i_write_back_w_reg_lo_data),

        //! read
        .o_hi_reg_data(read_hi_data),                       .o_lo_reg_data(read_lo_data)
    );

    //! 新增CTRL模块
    ctrl ctrl0(
        .rst(rst),
        .i_inst_decode_stall_req(o_inst_decode_stall_req),
        .i_execute_stall_req(o_execute_stall_req),
        .o_stall_req(stall_req)
    );

    //! 新增：DIV模块
    div div0(
        .rst(rst),                                          .clk(clk),

        .i_signed_div_en(signed_div_en),
        .i_opdata1(div_opdata1),                            .i_opdata2(div_opdata2),
        .i_start_en(div_start_en),                          .i_annul_en(1'b0),

        .o_result(div_result),                              .o_ready_en(div_ready_en)
    );
endmodule

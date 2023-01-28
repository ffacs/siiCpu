`include "mem_ctrl.v"
`include "define.v"
`include "memory.v"

module test_mem_ctrl ();
reg ex_en;
reg [`DATA_WIDTH_MEM_OP - 1:0] mem_op;
reg [`DATA_WIDTH_GPR - 1:0] mem_wr_data;
reg [`DATA_WIDTH_GPR - 1:0] mem_addr_from_alu;
wire [`DATA_WIDTH_GPR - 1:0] rd_data_from_mem;
wire [`WORD_ADDR_BUS] addr_to_mem;
wire mem_op_as_;
wire rw;
wire [`DATA_WIDTH_GPR - 1:0] wr_data;
wire [`DATA_WIDTH_GPR - 1:0] mem_data_to_gpr;
wire miss_align;

reg clk;
reg rst_;

integer i;

always #5 clk = ~clk;

mem_ctrl u_mem_ctrl(
    .ex_en(ex_en),
    .mem_op(mem_op),
    .mem_wr_data(mem_wr_data),
    .mem_addr_from_alu(mem_addr_from_alu),
    .rd_data_from_mem(rd_data_from_mem),
    .addr_to_mem(addr_to_mem),
    .as_(as_),
    .rw(rw),
    .wr_data(wr_data),
    .mem_data_to_gpr(mem_data_to_gpr),
    .miss_align(miss_align)
);

memory u_memory(
    .clk(clk),
    .rst_(rst_),
    .memory_addr(addr_to_mem),
    .memory_as_(as_),
    .memory_rw(rw),
    .memory_wr_data(wr_data),
    .memory_rd_data(rd_data_from_mem)
);

initial begin
    #0 begin
        clk = 0;
        rst_ = 0;
    end
    #1 begin
        rst_ = 1;
    end
    #1 begin
        ex_en = 1;
        mem_op = `MEM_OP_STORE;
        for (i = 0; i < 40; i ++) begin
            @(posedge clk);
            #1 begin
                mem_addr_from_alu = i * 4 * 4;
                mem_wr_data = 32'b0000_0001_0010_0011_0100_0101_0110_0111;
            end
        end
    end
    #10 begin
        mem_wr_data = 0;
        mem_addr_from_alu = 0;
        mem_op = `MEM_OP_LOAD_LH;
        for (i = 0; i < 40; i ++) begin
            @(posedge clk);
            #1 begin
                mem_addr_from_alu = i * 4;
            end
        end
    end
    #10
    $finish;
end

initial begin
    $dumpfile("wave_mem_ctrl.vcd");
    $dumpvars(0,test_mem_ctrl);
end

endmodule
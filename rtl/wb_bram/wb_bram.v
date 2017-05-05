//-----------------------------------------------------------------
// Wishbone BlockRAM
//-----------------------------------------------------------------

module wb_bram #(
	parameter mem_file_name0 = "none",
	parameter mem_file_name1 = "none",
	parameter mem_file_name2 = "none",
	parameter mem_file_name3 = "none",
	parameter adr_width = 11
) (
	input             clk_i, 
	input             rst_i,
	//
	input             wb_stb_i,
	input             wb_cyc_i,
	input             wb_we_i,
	output            wb_ack_o,
	input      [31:0] wb_adr_i,
	output reg [31:0] wb_dat_o,
	input      [31:0] wb_dat_i,
	input      [ 3:0] wb_sel_i
);

//-----------------------------------------------------------------
// Storage depth in 32 bit words
//-----------------------------------------------------------------
parameter word_width = adr_width - 2;
parameter word_depth = (1 << word_width); //4096... que es el tamño de la memoria que ya había instanciado dentro del system.v

//-----------------------------------------------------------------
// 
//-----------------------------------------------------------------
reg            [7:0] ram0 [0:word_depth-1];    // actual RAM
reg            [7:0] ram1 [0:word_depth-1];    // actual RAM
reg            [7:0] ram2 [0:word_depth-1];    // actual RAM
reg            [7:0] ram3 [0:word_depth-1];    // actual RAM
reg                   ack;
wire [word_width-1:0] adr;

assign adr        = wb_adr_i[adr_width-1:2];      // 
assign wb_ack_o   = wb_stb_i & ack;

always @(posedge clk_i)
begin
	if (wb_stb_i && wb_cyc_i) 
	begin
		if (wb_we_i && wb_sel_i[0]) 
			ram0[ adr ] <= wb_dat_i[7:0];
        if (wb_we_i && wb_sel_i[1]) 
			ram1[ adr ] <= wb_dat_i[15:8];
        if (wb_we_i && wb_sel_i[2]) 
			ram2[ adr ] <= wb_dat_i[23:16];
        if (wb_we_i && wb_sel_i[3]) 
			ram3[ adr ] <= wb_dat_i[31:24];

		wb_dat_o <= {ram3[ adr ],ram2[ adr ],ram1[ adr ],ram0[ adr ]};
		ack <= ~ack;
	end else
		ack <= 0;
    
end

initial 
begin
	if (mem_file_name0 != "none" && mem_file_name1 != "none" && mem_file_name2 != "none" && mem_file_name3 != "none")
	begin
		$readmemh(mem_file_name0, ram0);
		$readmemh(mem_file_name1, ram1);
		$readmemh(mem_file_name2, ram2);
		$readmemh(mem_file_name3, ram3);
	end
end

endmodule


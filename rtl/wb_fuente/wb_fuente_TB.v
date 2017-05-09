`timescale 10ns / 10ps
`define SIMULATION

module wb_fuente_TB;

	reg  clk;
   	reg  rst;
   
   	reg              	wb_stb_i;
	reg              	wb_cyc_i;
	wire             	wb_ack_o;
	reg              	wb_we_i;
	reg       	[31:0] wb_adr_i;
	reg        	[3:0] 	wb_sel_i;
	reg       	[31:0] wb_dat_i;
	wire  		[31:0] wb_dat_o;
   	
   	wb_fuente test (clk, rst, wb_stb_i, wb_cyc_i, wb_ack_o, wb_we_i, wb_adr_i, wb_sel_i, wb_dat_i, wb_dat_o);
   	
	always #1 clk = ~clk; 
	
	initial begin
        	#1000
       	$finish;
   	end
	
	initial begin  // Initialize Inputs
		clk 		= 0; 
		rst 		= 0;
		wb_stb_i	= 0;
		wb_cyc_i	= 0;
		wb_we_i	= 0;
		wb_adr_i	= 0;
		wb_sel_i	= 0;
		wb_dat_i	= 0;
	end
	
	initial begin
		#10
		rst = 1'b1;
		#10
		rst = 1'b0;
		#10
		wb_dat_i = 32'h00000038;
		wb_adr_i = 32'h00000004;
		#10
		wb_stb_i = 1'b1;
		wb_cyc_i = 1'b1;
		wb_we_i  = 1'b1;
		#4
		wb_stb_i = 1'b0;
		wb_cyc_i = 1'b0;
		wb_we_i  = 1'b0;
		#10
		wb_dat_i = 32'h00000001;
		wb_adr_i = 32'h00000000;
		#10
		wb_stb_i = 1'b1;
		wb_cyc_i = 1'b1;
		wb_we_i  = 1'b1;
		#4
		wb_stb_i = 1'b0;
		wb_cyc_i = 1'b0;
		wb_we_i  = 1'b0;
		#10
		wb_dat_i = 32'h00000000;
		wb_adr_i = 32'h00000000;
		#10
		wb_stb_i = 1'b1;
		wb_cyc_i = 1'b1;
		wb_we_i  = 1'b1;
		#4
		wb_stb_i = 1'b0;
		wb_cyc_i = 1'b0;
		wb_we_i  = 1'b0;
		#10
		wb_dat_i = 32'h00000000;
		wb_adr_i = 32'h00000008;
		#10
		wb_stb_i = 1'b1;
		wb_cyc_i = 1'b1;
		wb_we_i  = 1'b0;
		#4
		wb_stb_i = 1'b0;
		wb_cyc_i = 1'b0;
		wb_we_i  = 1'b0;
	end
		
	initial begin
     		$dumpfile("wb_fuente_TB.vcd");
     		$dumpvars(-1, test);
   	end

endmodule

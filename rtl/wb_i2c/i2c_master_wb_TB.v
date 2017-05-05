`timescale 10ns / 10ps
`define SIMULATION

module i2c_master_wb_TB;

	reg  clk = 1'b0;
   	reg  rst;
   
   	reg              	wb_stb_i;
	reg              	wb_cyc_i;
	wire             	wb_ack_o;
	reg              	wb_we_i;
	reg       	[31:0] wb_adr_i;
	reg        	[3:0] 	wb_sel_i;
	reg       	[31:0] wb_dat_i;
	wire  		[31:0] wb_dat_o;
	wire 			i2c_scl, i2c_sda;
   	
   	reg sda_out = 1'bz;
    	assign i2c_sda = sda_out;
   	
   	i2c_master_wb test 
	(	.clk(clk),
		.reset(rst),
	// Wishbone interface
		.wb_stb_i(wb_stb_i),
		.wb_cyc_i(wb_cyc_i),
		.wb_ack_o(wb_ack_o),
		.wb_we_i(wb_we_i),
		.wb_adr_i(wb_adr_i),
		.wb_sel_i(wb_sel_i),
		.wb_dat_i(wb_dat_i),
		.wb_dat_o(wb_dat_o),
	// I2C Wires
		.sda(i2c_sda),
		.scl(i2c_sda)
	);
   	
	always #1 clk = ~clk; 
	
	initial begin
        	#40000
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
		wb_dat_i = 32'h00000001;
		wb_adr_i = 32'h00000008;
		#10
		wb_stb_i = 1'b1;
		wb_cyc_i = 1'b1;
		wb_we_i  = 1'b1;
		#4
		wb_stb_i = 1'b0;
		wb_cyc_i = 1'b0;
		wb_we_i  = 1'b0;
		#10
		wb_dat_i = 32'h0000003C;
		wb_adr_i = 32'h0000000C;
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
		wb_we_i  = 1'b0;
		#4
		wb_stb_i = 1'b0;
		wb_cyc_i = 1'b0;
		wb_we_i  = 1'b0;
		while(wb_dat_o[0] == 1'b1) begin
		#10
		wb_dat_i = 32'h00000000;
		wb_adr_i = 32'h00000000;
		#10
		wb_stb_i = 1'b1;
		wb_cyc_i = 1'b1;
		wb_we_i  = 1'b0;
		#4
		wb_stb_i = 1'b0;
		wb_cyc_i = 1'b0;
		wb_we_i  = 1'b0;
		end 
		#10
		wb_dat_i = 32'h00000001;
		wb_adr_i = 32'h00000014;
		#10
		wb_stb_i = 1'b1;
		wb_cyc_i = 1'b1;
		wb_we_i  = 1'b1;
		#4
		wb_stb_i = 1'b0;
		wb_cyc_i = 1'b0;
		wb_we_i  = 1'b0;	
	end
	/*
	initial begin
        #159009			//Simulación de la señal proveniente del esclavo
        sda_out = 1'b1;		//con la dirección 38
        @(posedge i2c_scl);
        @(posedge i2c_scl);
        sda_out = 1'b0;
        @(posedge i2c_scl);
        sda_out = 1'b1;
        @(posedge i2c_scl);
        sda_out = 1'b0;
        @(posedge i2c_scl);
        sda_out = 1'b1;
        @(posedge i2c_scl);
        @(posedge i2c_scl);
        sda_out = 1'b0;
        @(posedge i2c_scl);
        @(posedge i2c_scl);
        sda_out = 1'bz;
    	end
	*/	
	initial begin
     		$dumpfile("i2c_master_wb_TB.vcd");
     		$dumpvars(-1, test);
   	end

endmodule


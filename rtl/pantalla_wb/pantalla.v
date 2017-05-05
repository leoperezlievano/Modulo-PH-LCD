module pantalla(clk, rst, rd, wr, addr_rd, posx, posy, caracter, dout);

/*			   _____________
	clk	-------->|	    RAM |	
	rst	-------->|		|
			 |  		|
	posx	-------->|		|				
	posy    -------->|   pantalla	|				
	wr	-------->|		|
	caracter-------->|		|				
		         |  		|
	addr_rd -------->|	   	|-------->	d_out		
	rd	-------->|______________|				
*/


input clk, rst, rd, wr;
input [9:0] addr_rd;
input [6:0] posx;
input [5:0] posy;
input [6:0] caracter;

output wire [7:0] dout;

wire rd_ROM, din_RAM, wr_RAM;
wire [9:0] addr_rd_ROM;
wire [12:0] addr_wr_RAM;
wire [7:0] dout_ROM;

RAM_pantalla ram(.clk(clk), .rst(rst), .d_in(din_RAM), .addr_wr(addr_wr_RAM), .wr(wr_RAM), .d_out(dout), .addr_rd(addr_rd), .rd(rd));

ROM_fuente rom(.clk(clk), .rst(rst), .addr_rd(addr_rd_ROM), .rd(rd_ROM), .d_out(dout_ROM));

control_pantalla control(.clk(clk), .rst(rst), .wr(wr), .posx(posx), .posy(posy), .caracter(caracter), .doutROM(dout_ROM), .rdROM(rd_ROM), .addrROM(addr_rd_ROM), .wrRAM(wr_RAM), .addrRAM(addr_wr_RAM), .dinRAM(din_RAM));

endmodule

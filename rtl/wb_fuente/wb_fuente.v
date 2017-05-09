/*Wishbone Fuente 

Register Description:
Escritura		rd              //0x00
			addr_rd 	//0x04
Lectura			d_out		//0x08
*/


module wb_fuente(
        input              clk,
	input              reset,
	// Wishbone interface
	input              wb_stb_i,
	input              wb_cyc_i,
	output             wb_ack_o,
	input              wb_we_i,
	input       [31:0] wb_adr_i,
	input        [3:0] wb_sel_i,
	input       [31:0] wb_dat_i,
	output reg  [31:0] wb_dat_o
);


/*			   _____________
	clk	-------->|	    ROM |	
	rst	-------->|		|
			 |  		|
	                 |  ROM_fuente	|				
	                 |  		|
	addr_rd -------->|	   	|-------->	d_out		
	rd	-------->|______________|					
*/


//---------------------------------------------------------------------------
// Actual wires pantalla engine
//---------------------------------------------------------------------------

//Se declaran como registros las entradas del módulo

reg rd = 1'b0;
reg [9:0] addr_rd;

//Se declaran como wires las salidas del módulo

wire [7:0] d_out;

ROM_fuente rom0 (.clk(clk), .rst(reset), .addr_rd(addr_rd), .rd(rd), .d_out(d_out));

wire wb_rd = wb_stb_i & wb_cyc_i & ~wb_we_i;
wire wb_wr = wb_stb_i & wb_cyc_i &  wb_we_i;

reg  ack; // aún no se que es esto

assign wb_ack_o = wb_stb_i & wb_cyc_i & ack;


always @(posedge clk) begin
	if (reset) begin
		wb_dat_o[31:0] 		        <= 32'b0;
		rd				<= 1'b0;		
		addr_rd  			<= 10'b0;
		
	end else begin
		wb_dat_o[31:8] <= 24'b0;
		ack  <= 0;
		//Lectura y escritura de registros
		if (wb_rd & ~ack) begin			//Salidas del whisbone
			ack <= 1;
			wb_dat_o[7:0] <= d_out;						    //0x08
		end else if (wb_wr & ~ack ) begin 	//Entradas del whisbone
			ack 		<= 1;	
			case (wb_adr_i[3:2]) 
			3'b00: begin 	        rd  		<= wb_dat_i[0]; 	end //0x00
			3'b01: begin		addr_rd		<= wb_dat_i[9:0]; 	end //0x04
			default: begin 	        wb_dat_o[7:0]   <= 8'b0; 		end
			endcase
		end
	end
end

endmodule

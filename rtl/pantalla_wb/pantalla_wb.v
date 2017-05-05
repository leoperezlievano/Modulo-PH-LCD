/*
			rd               //0x00
			wr		 //0x04
			posx             //0X08
			posy    	 //0X0C
			caracter         //0x10
			addr_rd 	 //0x14
*/


module pantalla_wb(
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


//---------------------------------------------------------------------------
// Actual wires pantalla engine
//---------------------------------------------------------------------------

//Se declaran como registros las entradas del módulo

reg rd = 1'b0;
reg wr = 1'b0;     
reg [6:0] posx ;
reg [5:0] posy ;
reg [6:0]     caracter;
reg [9:0]     addr_rd;

//Se declaran como wires las salidas del módulo

wire  [7:0] d_out;

pantalla pantalla0 (.clk(clk), .rst(reset), .rd(rd), .wr(wr), .addr_rd(addr_rd), .posx(posx), .posy(posy), .caracter(caracter), .dout(d_out));

wire wb_rd = wb_stb_i & wb_cyc_i & ~wb_we_i;
wire wb_wr = wb_stb_i & wb_cyc_i &  wb_we_i;

reg  ack; // aún no se que es esto

assign wb_ack_o = wb_stb_i & wb_cyc_i & ack;


always @(posedge clk) begin
	if (reset) begin
		wb_dat_o[31:0] 		        <= 32'b0;
		rd				<= 1'b0;		
		wr				<= 1'b0;
		posx				<= 7'b0;
	        posy			        <= 6'b0;
		caracter			<= 7'b0;
		addr_rd  			<= 10'b0;
		
	end else begin
		wb_dat_o[31:8] <= 24'b0;
		ack  <= 0;
		//Lectura y escritura de registros
		if (wb_rd & ~ack) begin
			ack <= 1;
			
			wb_dat_o[7:0] <= d_out;
		end else if (wb_wr & ~ack ) begin //entradas
			ack 		<= 1;	
			case (wb_adr_i[4:2]) 
			3'b000: begin 	        rd  		<= wb_dat_i[0]; 	end //0x00
			3'b001: begin		wr		<= wb_dat_i[0]; 	end //0x04
			3'b010: begin		posx		<= wb_dat_i[6:0]; 	end //0X08
			3'b011: begin		posy    	<= wb_dat_i[5:0]; 	end //0X0C
			3'b100: begin   	caracter 	<= wb_dat_i[6:0];	end //0x10
			3'b101: begin   	addr_rd 	<= wb_dat_i[9:0];	end //0x14
			default: begin 	        wb_dat_o[7:0]   <= 8'b0; 		end
			endcase
		end
	end
end

endmodule

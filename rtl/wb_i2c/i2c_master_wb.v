/*---------------------------------------------------------------------------
Wishbone I2C 

Register Description:

Lectura    	0x00 i2c_state      [ 0 | 0 | 0 | 0 | 0 | ack_error | 0 | busy ]
    		0x04 data_rd
Escritura	0x08 rw
		0x0C addr
		0x10 data_wr
		0x14 ena	

---------------------------------------------------------------------------*/

module i2c_master_wb (
	
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
	output reg  [31:0] wb_dat_o,
	// I2C Wires
	inout              sda,
	inout              scl
);

//---------------------------------------------------------------------------
// Actual i2c engine
//---------------------------------------------------------------------------

//Se declaran como registros las entradas del módulo

reg ena, rw;  
reg [6:0]     addr ;
reg [7:0]     data_wr;

//Se declaran como wires las salidas del módulo

wire busy , ack_error;
wire  [7:0] data_rd;

i2c_master i2c0 (.clk(clk), .reset(reset), .ena(ena), .addr(addr), .rw(rw), .data_wr(data_wr), .busy(busy), .data_rd(data_rd), .ack_error(ack_error), .sda(sda), .scl(scl));

wire wb_rd = wb_stb_i & wb_cyc_i & ~wb_we_i;
wire wb_wr = wb_stb_i & wb_cyc_i &  wb_we_i;

reg  ack; // aún no se que es esto

wire [7:0] i2c_state= { 5'b0,ack_error,1'b0, busy};

assign wb_ack_o = wb_stb_i & wb_cyc_i & ack;

/*
                   ____________
 clk     -------->|            |--------> busy                          |
 reset   -------->|            |--------> ack_error                     |CONTROL SIGNALS 
 ena     -------->|            |                                        |
                  | i2c_master |
 rw      -------->|            |--------> data_rd                       |
 addr    -------->|            |<-------> sda                           |DATA SIGNALS
 data_wr -------->|____________|<-------> scl                           |

*/

//ESTO ES DE LA UART
always @(posedge clk) begin
	if (reset) begin
		wb_dat_o[31:0] 	<= 32'b0;
		ena  			<= 1'b0;
		rw 				<= 1'b0;
		addr			<= 7'b0;
		data_wr			<= 8'b0;
		ack  			<= 1'b0;
		
	end else begin
		wb_dat_o[31:8] <= 24'b0;
		ack  <= 0;
		//Lectura y escritura de registros
		if (wb_rd & ~ack) begin
			ack <= 1;
			case (wb_adr_i[4:2])
			3'b000: begin	wb_dat_o[7:0] <= i2c_state; end //0x00
			3'b001: begin	wb_dat_o[7:0] <= data_rd; 	end //0x04
			default: begin 	wb_dat_o[7:0] <= 8'b0; 		end
			endcase
		end else if (wb_wr & ~ack ) begin
			ack <= 1;	
			case (wb_adr_i[4:2]) 
			3'b010: begin 	rw  	<= wb_dat_i[0]; 	end //0x08
			3'b011: begin	addr	<= wb_dat_i[6:0]; 	end //0x0C
			3'b100: begin	data_wr <= wb_dat_i[7:0]; 	end //0X10
			3'b101: begin	ena 	<= wb_dat_i[0]; 	end //0X14
			default: begin 	wb_dat_o[7:0]  <= 8'b0; 	end
			endcase
		end
	end
end

endmodule 

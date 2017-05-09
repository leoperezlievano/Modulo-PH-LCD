//---------------------------------------------------------------------------
// Wishbone I2C 
//
// Register Description:
//
//    0x00 SCR      [ 0 | 0 | 0 | 0 | 0 | i2c_busy  | start | ack ]
//    0x04 SET	    [ 10'h0 | tx_data | s_reg | s_address ]
//---------------------------------------------------------------------------

module i2c_master_wb(
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
	// Serial Wires
	inout              i2c_sda,
	output 		   i2c_scl
);

//---------------------------------------------------------------------------
// Actual I2C engine
//---------------------------------------------------------------------------
wire [7:0] i2c_rx_data;
wire       done;
wire       ack;
wire [7:0] i2c_tx_data;
wire       i2c_busy;
wire [6:0] slave_address;
wire [7:0] slave_reg;
wire       start;
wire	   rw;
wire 	   i2c_sclk;

reg  [7:0] s_reg;
reg  [6:0] s_address;
reg  [7:0] rx_data;
reg  [7:0] tx_data;
reg        i2c_rw;
reg        start_reg = 1'b1;

//Se instancia el módulo I2C Master

i2c      i2c0  (
	.clk(clk),
	.i2c_sclk(i2c_sclk),	//Buses de comunicación I2C
	.i2c_sdat(i2c_sda),
	.reset(reset),
	//
	.start(start),
	.rw(rw),
	.slave_address(slave_address),
	.slave_reg(slave_reg),
	.i2c_tx_data(i2c_tx_data),
	.done(done),
	.ack(ack),
	.i2c_rx_data(i2c_rx_data),
	.i2c_busy(i2c_busy)
);

//---------------------------------------------------------------------------
// 
//---------------------------------------------------------------------------
wire [7:0] scr = { 5'b0, i2c_busy, start, ack};

//Done indica que la comunicación ha finalizado (tanto lectura como escritura)
//start_reg está ligado a la inicialización del módulo de comunicación
//ack indica que se ha recibido-enviado toda la información correctamente
//i2c_busy indica que el módulo de comunicación se encuentra ocupado ejecutando una operación

wire wb_rd = wb_stb_i & wb_cyc_i & ~wb_we_i;
wire wb_wr = wb_stb_i & wb_cyc_i &  wb_we_i;

reg  ack_wb;

assign wb_ack_o = wb_stb_i & wb_cyc_i & ack_wb;

assign slave_address = s_address; 
assign slave_reg = s_reg;
assign i2c_tx_data = tx_data;
assign start = start_reg; 
assign rw = i2c_rw;

always @(posedge clk)
begin
	if(done & ~wb_rd & ~wb_wr)  start_reg <= 1'b1;	

	if (reset) begin //Se reinicia el bus de datos
		wb_dat_o[31:0] 	<= 32'b0;
		i2c_rw  	<= 1'b0;
		start_reg 	<= 1'b1;
		ack_wb    	<= 1'b0;
		s_address 	<= 7'd0; 
		s_reg     	<= 8'd0;
		tx_data   	<= 8'd0;
	end else begin //Comenzar la comunicación
		wb_dat_o[31:8] <= 24'b0;
		ack_wb    <= 1'b0;

		if (wb_rd & ~ack_wb) begin //Operación de lectura Wishbone
			
			ack_wb <= 1'b1;

			case (wb_adr_i[2])
			1'b0: begin					//0x00			
				wb_dat_o[7:0] <= scr; 			//Mostrar registro de estado
			end
			1'b1: begin					//0x04
				i2c_rw 		<= 1'b0;
				start_reg 	<= 1'b0;
				s_address	<= wb_dat_i[6:0]; 
				s_reg     	<= wb_dat_i[15:8];
				wb_dat_o[7:0] 	<= i2c_rx_data; 	//Mostrar registro de datos recibidos	
			end
			default: begin
				wb_dat_o[7:0] 	<= 8'b0;	
			end
			endcase

		end else if (wb_wr & ~ack_wb) begin //Operación de escritura Wishbone
			
			ack_wb <= 1'b1;

			case (wb_adr_i[2])
			1'b1:begin					//0x04
				i2c_rw 		<= 1'b1;
				start_reg 	<= 1'b0;
				s_address 	<= wb_dat_i[6:0]; 
				s_reg     	<= wb_dat_i[15:8];
				tx_data   	<= wb_dat_i[23:16];
			end
			default: begin
				wb_dat_o[7:0] 	<= 8'b0;	
			end
			endcase
		end 
	end
end

assign i2c_scl = (!i2c_sclk) ? 1'b0 : 1'bz;

endmodule	

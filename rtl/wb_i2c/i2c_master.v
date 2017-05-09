`timescale 1ns / 1ps

module i2c(
    input  				clk,
    output 				i2c_sclk,
    inout  				i2c_sdat,
    input 				reset,
    input  				start,
    input  				rw,
    input [6:0] 		        slave_address,
    input [7:0]		                slave_reg,
    input [7:0]		                i2c_tx_data,
    output 				done,
    output 				ack,
    output reg [7:0]	                i2c_rx_data,
    output reg			        i2c_busy
);

reg [7:0] data;
reg [5:0] stage;
reg [10:0] sclk_divider;
reg clock_en;
reg [6:0] address;
reg [7:0] slave_register;
reg rep_start;

// don't toggle the clock unless we're sending data
// clock will also be kept high when sending START and STOP symbols
assign i2c_sclk = (!clock_en) || (sclk_divider >= 11'd512);
wire midlow = (sclk_divider >= 11'd453); //Para ajustar la subida de SDA antes de SCL


reg sdat = 1'b1;
// rely on pull-up resistor to set SDAT high
assign i2c_sdat = (sdat) ? 1'bz : 1'b0;

reg [3:0] acks;
reg finish;


assign ack = (acks == 4'b1000);
assign done = finish;

always @(posedge clk) 
	begin
	if(reset) 
	  begin
	  i2c_busy 	<= 1'b0;
	  sdat 		<= 1'b1;
	  clock_en 	<= 1'b0;
	  finish 	<= 1'b0;
	  stage 	<= 5'b0;
	  sclk_divider 	<= 11'd0;
	  acks 		<= 4'b0111;
	  data 		<= 8'b00000000;
	  address 	<= 7'b0000000;
	  slave_register <= 8'b00000000;
	  i2c_rx_data	<= 8'h00;
	  end 
	else 
	  begin 
	  if(rep_start) 
	     begin
	     clock_en <= 1'b0;
	     rep_start <= 1'b0;
	     end 
	  else if(start)
	     begin
	     data <= i2c_tx_data;
	     slave_register <= slave_reg;
	     address <= slave_address;
	     sclk_divider <= 11'd0;
	     i2c_busy <= 1'b0;
	     stage <= 5'd0;
	     clock_en <= 1'b0;
	     sdat <= 1'b1;
	     end 
	  else 
	     begin
	     finish <= 1'b0;
	     i2c_busy <= 1'b1;
	     acks <= 4'b0111;
             if (sclk_divider == 11'd1024)
		begin
	  	sclk_divider <= 11'd0;		
	 	  if (~finish)
	          stage <= stage + 1'b1;

            case (stage)
                // after start
                6'd0:  clock_en <= 1'b1;
                // receive acks
                6'd9:  acks[0] <= i2c_sdat;
                6'd18: acks[1] <= i2c_sdat;
		6'd20: if(~rw) clock_en <= 1'b1;
		6'd27: begin if(rw)begin
				acks[2] <= i2c_sdat;
				acks[3] <= 1'b1;
				end
        	       end
		6'd29: if(~rw) acks[2] <= i2c_sdat;
		6'd30: if(~rw) data[7] <= i2c_sdat;
		6'd31: if(~rw) data[6] <= i2c_sdat;
		6'd32: if(~rw) data[5] <= i2c_sdat;
		6'd33: if(~rw) data[4] <= i2c_sdat;
		6'd34: if(~rw) data[3] <= i2c_sdat;
		6'd35: if(~rw) data[2] <= i2c_sdat;
		6'd36: if(~rw) data[1] <= i2c_sdat;
		6'd37: if(~rw) data[0] <= i2c_sdat;
		6'd38: if(~rw) acks[3] <= 1'b1;

                // before stop
            endcase
        end else
            sclk_divider <= sclk_divider + 1'b1;

        if (midlow && rw) begin //Lógica de escritura (rw = 1)
            case (stage)
                // start
                6'd0:  sdat <= 1'b0;       // byte 1
		6'd1:  sdat <= slave_address[6];
                6'd2:  sdat <= slave_address[5];
                6'd3:  sdat <= slave_address[4];
                6'd4:  sdat <= slave_address[3];
                6'd5:  sdat <= slave_address[2];
                6'd6:  sdat <= slave_address[1];
                6'd7:  sdat <= slave_address[0];
                6'd8:  sdat <= 1'b0; 	   //Bit de Lectura/Escritura
                // ack 1
                6'd9:  sdat <= 1'b1;    
                // byte 2
                6'd10: sdat <= slave_reg[7]; //Envío de la dirección del registro del esclavo
                6'd11: sdat <= slave_reg[6];
                6'd12: sdat <= slave_reg[5];
                6'd13: sdat <= slave_reg[4];
                6'd14: sdat <= slave_reg[3];
                6'd15: sdat <= slave_reg[2];
                6'd16: sdat <= slave_reg[1];
                6'd17: sdat <= slave_reg[0];
                // ack 2
                6'd18: sdat <= 1'b1;
                // byte 3 Escritura de datos
                6'd19: sdat <= i2c_tx_data[7];
                6'd20: sdat <= i2c_tx_data[6];
                6'd21: sdat <= i2c_tx_data[5];
                6'd22: sdat <= i2c_tx_data[4];
                6'd23: sdat <= i2c_tx_data[3];
                6'd24: sdat <= i2c_tx_data[2];
                6'd25: sdat <= i2c_tx_data[1];
                6'd26: sdat <= i2c_tx_data[0];
                // ack 3
                6'd27: sdat <= 1'b1;
                // stop
                6'd28: begin 
			sdat <= 1'b0;
			clock_en <= 1'b0;
		end
                6'd29: begin
			sdat <= 1'b1;
			i2c_busy <= 1'b0;
			finish <= 1'b1;
		end	
	endcase
	end
	if (midlow && (~rw)) begin //Lógica de lectura (rw = 0)
            case (stage)
                // start
                6'd0:  sdat <= 1'b0;
                // byte 1
		6'd1:  sdat <= slave_address[6];
                6'd2:  sdat <= slave_address[5];
                6'd3:  sdat <= slave_address[4];
                6'd4:  sdat <= slave_address[3];
                6'd5:  sdat <= slave_address[2];
                6'd6:  sdat <= slave_address[1];
                6'd7:  sdat <= slave_address[0];
                6'd8:  sdat <= 1'b0; //Bit de Lectura/Escritura
                // ack 1
                6'd9:  sdat <= 1'b1;
                // byte 2
                6'd10: sdat <= slave_reg[7];	//Envío de la dirección del registro del esclavo
                6'd11: sdat <= slave_reg[6];
                6'd12: sdat <= slave_reg[5];
                6'd13: sdat <= slave_reg[4];
                6'd14: sdat <= slave_reg[3];
                6'd15: sdat <= slave_reg[2];
                6'd16: sdat <= slave_reg[1];
                6'd17: sdat <= slave_reg[0];
                // ack 2
                6'd18: sdat <= 1'b1;
					 //Repetir condicion de inicio
		6'd19: begin 
			rep_start <= 1'b1;
			sdat <= 1'b1;
		end
		6'd20:  sdat <= 1'b0;
					 // Volver a enviar la direccion del esclavo
                6'd21:  sdat <= slave_address[6];
                6'd22:  sdat <= slave_address[5];
                6'd23:  sdat <= slave_address[4];
                6'd24:  sdat <= slave_address[3];
                6'd25:  sdat <= slave_address[2];
                6'd26:  sdat <= slave_address[1];
                6'd27:  sdat <= slave_address[0];
                6'd28:  sdat <= 1'b1;    // Confirmación de lectura
					 //ack3
                6'd29: sdat <= 1'b1;
                // recepción de datos
		6'd30: sdat <= 1'b1;
		6'd31: sdat <= 1'b1;
		6'd32: sdat <= 1'b1;
		6'd33: sdat <= 1'b1;
		6'd34: sdat <= 1'b1;
		6'd35: sdat <= 1'b1;
		6'd36: sdat <= 1'b1;
		6'd37: sdat <= 1'b1;
		//ack4
		6'd38: sdat <= 1'b1;
		//Finalizar la operación
                6'd39: begin 
			sdat <= 1'b0;
			clock_en <= 1'b0;
		end
		6'd40: begin
			sdat <= 1'b1;
			i2c_rx_data <= data;
			i2c_busy <= 1'b0;
			finish <= 1'b1;
		end
            endcase
	    end
        end
    end
end

endmodule

module ROM_fuente (clk, rst, addr_rd, rd, d_out, ena_led, led);
/*              	  ______________
	clk	-------->|	    ROM |	
	rst	-------->|		|
			 |  		|
	ena_led -------->|   fuente	|				
	                 |  		|
	addr_rd -------->|	   	|-------->	d_out		
	rd	-------->|______________|-------->      led				

*/

input clk, rst, rd;
input [9:0] addr_rd;       //Dirección de lectura
input ena_led;
output wire led;
output reg [7:0] d_out;     //Dato de salida

assign led = ena_led;

reg [7:0] rom [0:1023];     // 1024-bit x 8-bit ROM

       	initial begin
                $readmemh("../fuente_6x8.list", rom);
        end

        always @(negedge clk) begin
		if (rst == 1'b1) begin
			d_out <= 8'd0;
		end 
		else begin
			if (rd) begin	//Lectura de la memoria ROM
				d_out <= rom[addr_rd];
			end 
		end
	end

endmodule

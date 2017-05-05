module control_pantalla (clk, rst, wr, posx, posy, caracter, doutROM, rdROM, addrROM, wrRAM, addrRAM, dinRAM);

/*			  ______________________
	clk	-------->|	                |	
	rst	-------->|		        |-------->	rdROM
			 |  		        |-------->	addrROM
	wr	-------->|		        |       			
	posx    -------->|   control_pantalla	|				
	posy	-------->|		        |				
	caracter-------->|		        |-------->	wrRAM
			 |  		        |-------->	addrRAM
	doutROM	-------->|		        |
	                 |	   	        |-------->	dinRAM		
                         |______________________|				
*/

input wr, clk, rst;
input [6:0] posx;
input [5:0] posy;
input [6:0] caracter;
input [7:0] doutROM;    //dato que contiene la fuente

output reg rdROM, wrRAM;
output wire dinRAM;
output wire [9:0] addrROM;
output wire [12:0] addrRAM;

reg [2:0] btc;
reg [2:0] ncolumna;

assign dinRAM   = doutROM [btc];
assign addrROM  = (caracter*6)+ncolumna;
assign addrRAM  = {(posy+btc),(posx+ncolumna)};

localparam S_WAIT       = 3'd0;
localparam S_RD_FONT    = 3'd1;
localparam S_WR_RAM     = 3'd2;
localparam S_ADD_BTC    = 3'd3;
localparam S_ADD_NCOL   = 3'd4;

reg [2:0] state         = S_WAIT;

always @(posedge clk) begin

        if(rst) begin
                btc = 3'd0;
                ncolumna = 3'd0;
                rdROM = 0;      
                wrRAM = 0;        
                state = S_WAIT;
        end else begin
        
                case(state)
                        
                        S_WAIT: begin 
                                if(wr == 0) begin // (0)
                                        btc = 3'd0;
                                        ncolumna = 3'd0;
                                        rdROM = 0;
                                        wrRAM = 0; 
                                        state = S_WAIT;
                                end else begin //(1)
                                        btc = 3'd0;
                                        ncolumna = 3'd0;
                                        rdROM = 1;
                                        wrRAM = 0; 
                                        state = S_RD_FONT;
                                end        
                        end
                        
                        S_RD_FONT: begin //(2)
                               btc = 3'd0;
                               ncolumna = ncolumna;
                               rdROM = 0;
                               wrRAM = 1; 
                               state = S_WR_RAM; 
                        end
                        
                        S_WR_RAM: begin
                                if(btc < 7)begin //(3)
                                        btc = btc+1;
                                        ncolumna = ncolumna;
                                        rdROM = 0;
                                        wrRAM = 0; 
                                        state = S_ADD_BTC;
                                end else begin //(5)
                                        btc = 3'd0;
                                        ncolumna = ncolumna+1;
                                        rdROM = 0;
                                        wrRAM = 0; 
                                        state = S_ADD_NCOL;
                                end   
                        end
                        
                        S_ADD_BTC: begin //(4)
                               btc = btc;
                               ncolumna = ncolumna;
                               rdROM = 0;
                               wrRAM = 1; 
                               state = S_WR_RAM; 
                        end
                        
                        S_ADD_NCOL: begin
                                if(ncolumna <= 5)begin
                                        btc = 3'd0;
                                        ncolumna = ncolumna;
                                        rdROM = 1;
                                        wrRAM = 0; 
                                        state = S_RD_FONT;
                                end else begin
                                        btc = 3'd0;
                                        ncolumna = 0;
                                        rdROM = 0;
                                        wrRAM = 0; 
                                        state = S_WAIT;
                                end
                        end
                endcase
        
        end

end

endmodule

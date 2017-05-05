`define log2(n)   ((n) <= (1<<0)  ? 0 : (n)  <= (1<<1)  ? 1  :\
                   (n) <= (1<<2)  ? 2 : (n)  <= (1<<3)  ? 3  :\
                   (n) <= (1<<4)  ? 4 : (n)  <= (1<<5)  ? 5  :\
                   (n) <= (1<<6)  ? 6 : (n)  <= (1<<7)  ? 7  :\
                   (n) <= (1<<8)  ? 8 : (n)  <= (1<<9)  ? 9  :\
                   (n) <= (1<<10) ? 10 : (n) <= (1<<11) ? 11 :\
                   (n) <= (1<<12) ? 12 : (n) <= (1<<13) ? 13 :\
                   (n) <= (1<<14) ? 14 : (n) <= (1<<15) ? 15 :\
                   (n) <= (1<<16) ? 16 : (n) <= (1<<17) ? 17 :\
                   (n) <= (1<<18) ? 18 : (n) <= (1<<19) ? 19 :\
                   (n) <= (1<<20) ? 20 : (n) <= (1<<21) ? 21 :\
                   (n) <= (1<<22) ? 22 : (n) <= (1<<23) ? 23 :\
                   (n) <= (1<<24) ? 24 : (n) <= (1<<25) ? 25 :\
                   (n) <= (1<<26) ? 26 : (n) <= (1<<27) ? 27 :\
                   (n) <= (1<<28) ? 28 : (n) <= (1<<29) ? 29 :\
                   (n) <= (1<<30) ? 30 : (n) <= (1<<31) ? 31 : 32)

module i2c_master (clk, reset, ena, addr, rw, data_wr, busy, data_rd, ack_error, sda, scl);

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

    input           clk, reset, ena, rw;
    input [6:0]     addr ;
    input [7:0]     data_wr;
    output reg      busy = 0, ack_error = 0;
    output reg [7:0]    data_rd;
    inout           sda, scl;
    
    parameter  input_clk = 100000000;
    parameter  bus_clk = 100000;
    localparam divider = (input_clk/bus_clk)/4;
    parameter  countWidth = `log2(divider*4);
    
    parameter ready     = 4'b0000;//0
    parameter start     = 4'b0001;//1
    parameter command   = 4'b0010;//2
    parameter slv_ack1  = 4'b0011;//3
    parameter wr        = 4'b0100;//4
    parameter rd        = 4'b0101;//5
    parameter slv_ack2  = 4'b0110;//6
    parameter mstr_ack  = 4'b0111;//7
    parameter stop      = 4'b1000;//8
    reg [3:0] state = ready;
    
    reg data_clk = 1'b0;
    reg data_clk_prev = 1'b0;
    reg scl_clk = 1'b0;
    reg scl_ena = 1'b0;
    reg sda_int = 1'b1;
    reg sda_ena_n = 1'b0;
    reg [7:0] addr_rw = 8'b0;
    reg [7:0] data_tx = 8'b0;
    reg [7:0] data_rx = 8'b0;
    reg stretch = 1'b0;
    
    reg [2:0] bit_cnt = 3'd7;
    
    reg [countWidth-1:0] count = 0;  //Arreglar tamano del contador.
    
    always @(posedge clk, posedge reset) begin
        if(reset) begin
            stretch = 1'b0;
            count = 0;
        end
        else begin
            data_clk_prev = data_clk;
            if(count == ((divider*4)-1))
                count = 0;
            else
                count = count + {{(countWidth-1){1'b0}},1'b1};
            if(count>=0 && count<divider) begin
                scl_clk = 1'b0;
                data_clk = 1'b0;
            end 
            else if(count>=divider && count<divider*2) begin
                scl_clk = 1'b0;
                data_clk = 1'b1;
            end
            else if(count>=divider*2 && count<divider*3) begin
                scl_clk = 1'b1;
                if(scl == 1'b0)
                    stretch = 1'b1;
                else
                    stretch = 1'b0;
                    data_clk = 1'b1;
            end
            else begin
                scl_clk = 1'b1;
                data_clk = 1'b0;
            end
        end
    end
    
    always @(negedge clk, posedge reset) begin
        if(reset) begin
            state       <= ready;                //return to initial state
            busy        <= 1'b1;                 //indicate not available 
            scl_ena     <= 1'b0;                 //sets scl high impedance 
            sda_int     <= 1'b0;                 //sets sda high impedance 
            ack_error   <= 1'b0;                 //clear acknowledge error flag 
            bit_cnt     <= 7;                    //restarts data bit counter 
            data_rd     <= 8'd0;                 //clear data read port 
        end
        else begin
            if(data_clk && ~data_clk_prev) begin
                case (state)
                    ready: begin    //0
                        if(ena) begin
                            busy <= 1'b1;                   //flag busy
                            addr_rw <= {addr,rw};          //collect requested slave address 
                            data_tx <= data_wr;            //collect requested data to write
                            state <= start;                //go to start bit
                        end

                        else begin
                            busy <= 1'b0;                   //unflag busy
                            state <= ready;                //remain idle
                        end


                    end
                    start: begin    //1
                            busy <= 1'b1;                     //resume busy if continuous mode
                            sda_int <= addr_rw[bit_cnt];     //set first address bit to bus
                            state <= command;                //go to command
                    end

                    command: begin  //2
                        if(bit_cnt==0) begin
                            sda_int <= 1'b1;                //release sda for slave acknowledge
                            bit_cnt <= 7;                  //reset bit counter for "byte" states
                            state <= slv_ack1;             //go to slave acknowledge (command)
                        end

                        else begin
                            bit_cnt <= bit_cnt - 3'd1;        //keep track of transaction bits
                            sda_int <= addr_rw[bit_cnt-1]; //write address/command bit to bus
                            state <= command;              //continue with command
                        end
                    end

                    slv_ack1: begin //3
                        if(!addr_rw[0]) begin               //write command
                            sda_int <= data_tx[bit_cnt];    //write first bit of data
                            state <= wr;                    //go to write byte
                        end else begin                      
                            sda_int <= 1'b1;                 //release sda from incoming data
                            state <= rd;                    //go to read byte
                        end
                    end

                    wr: begin      //4                 //write byte of transaction
                        busy <= 1'b1;                     //resume busy if continuous mode
                        if(bit_cnt==1'b0) begin             //write byte transmit finished
                            sda_int <= 1'b1;                //release sda for slave acknowledge
                            bit_cnt <= 7;                  //reset bit counter for "byte" states
                            state <= slv_ack2;             //go to slave acknowledge (write)
                        end else begin                    //next clock cycle of write state
                            bit_cnt <= bit_cnt - 3'd1;        //keep track of transaction bits
                            sda_int <= data_tx[bit_cnt-1]; //write next bit to bus
                            state <= wr;                   //continue writing
                        end
                    end

                    rd: begin      //5                   //read byte of transaction
                        busy <= 1'b1;                    //resume busy if continuous mode
                        if(bit_cnt == 0) begin             //read byte receive finished
                            if(ena && (addr_rw == {addr,rw})) begin  //continuing with anot
                                sda_int <= 1'b0;      //acknowledge the byte has bee
                            end else begin           //stopping or continuing with a write
                                sda_int <= 1'b1;      //send a no-acknowledge (before stop or
                            end
                            bit_cnt <= 7;                  //reset bit counter for "byte" states
                            data_rd <= data_rx;            //output received data
                            state <= mstr_ack;             //go to master acknowledge
                        end else begin                    //next clock cycle of read state
                            bit_cnt <= bit_cnt - 3'd1;        //keep track of transaction bits
                            state <= rd;                   //continue reading
                        end
                    end

                    slv_ack2: begin//6                   //slave acknowledge bit (write)
                        if(ena) begin               //continue transaction
                            busy <= 1'b0;                   //continue is accepted
                            addr_rw <= {addr,rw};   //collect requested slave address and command
                            data_tx <= data_wr;            //collect requested data to write
                            if (addr_rw == {addr,rw}) begin //continue transaction with another
                                sda_int <= data_wr[bit_cnt]; //write first bit of data
                                state <= wr;                 //go to write byte
                            end else begin     //continue transaction with a read or new slave
                                state <= start;              //go to repeated start
                            end
                        end else begin                            //complete transaction
                            state <= stop;                 //go to stop bit
                        end
                    end

                    mstr_ack: begin //7                   //master acknowledge bit after a read
                        if(ena) begin               //continue transaction
                            busy <= 1'b0;    //continue is accepted and data received is avai
                            addr_rw <= {addr,rw};  //collect requested slave address and command
                            data_tx <= data_wr;            //collect requested data to write
                            if(addr_rw == {addr,rw}) begin   //continue transaction with anot
                                sda_int <= 1'b1;             //release sda from incoming data
                                state <= rd;                 //go to read byte
                            end else begin       //continue transaction with a write or new slave
                                state <= start;              //repeated start
                            end     
                        end else begin                             //complete transaction
                            state <= stop;                 //go to stop bit
                        end
                    end

                    stop: begin //8                      //stop bit of transaction
                        busy <= 1'b0;                     //unflag busy
                        state <= ready;                  //go to idle state
                    end
                endcase

            end else if (~data_clk && data_clk_prev) begin
                ack_error <= 0;
                case (state)
                    start: begin
                        if(scl_ena == 1'b0) begin                  //starting new transaction
                            scl_ena <= 1'b1;                       //enable scl output
                            ack_error <= 1'b0;           //reset acknowledge error output
                        end
                    end
                    slv_ack1: begin             //receiving slave acknowledge (command)
                        if(sda != 1'b0 || ack_error) begin  //no-acknowledge or previous n
                            ack_error <= 1'b1;        //set error output if no-acknowledge
                        end
                    end
                    rd: begin                         //receiving slave data
                        data_rx[bit_cnt] <= sda;                //receive current slave data bit
                    end
                    slv_ack2: begin         //receiving slave acknowledge (write)
                        if(sda != 1'b0 || ack_error) begin  //no-acknowledge or previous 
                            ack_error <= 1'b1;         //set error output if no-acknowledge
                        end
                    end
                    stop: begin
                        scl_ena <= 1'b0;                         //disable scl
                    end
                    default: begin
                        scl_ena <= scl_ena;  //NULL
                    end
                endcase
            end
        end
    end
    
    always @(state, data_clk_prev, data_clk_prev, sda_int) begin
        case(state)
            start:      sda_ena_n <= data_clk_prev;
            stop:       sda_ena_n <= data_clk_prev;
            default:    sda_ena_n <= sda_int;
        endcase
    end
    
    assign scl = (scl_ena && ~scl_clk) ? 1'b0 : 1'bz;
    assign sda = (!sda_ena_n) ? 1'b0 : 1'bz;

endmodule


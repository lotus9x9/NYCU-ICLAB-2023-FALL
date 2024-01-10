//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   (C) Copyright Laboratory System Integration and Silicon Implementation
//   All Right Reserved
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   2023 ICLAB Fall Course
//   Lab03      : BRIDGE
//   Author     : Ting-Yu Chang
//                
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   File Name   : BRIDGE_encrypted.v
//   Module Name : BRIDGE
//   Release version : v1.0 (Release Date: Sep-2023)
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################

module BRIDGE(
    // Input Signals
    clk,
    rst_n,
    in_valid,
    direction,
    addr_dram,
    addr_sd,
    // Output Signals
    out_valid,
    out_data,
    // DRAM Signals
    AR_VALID, AR_ADDR, R_READY, AW_VALID, AW_ADDR, W_VALID, W_DATA, B_READY,
	AR_READY, R_VALID, R_RESP, R_DATA, AW_READY, W_READY, B_VALID, B_RESP,
    // SD Signals
    MISO,
    MOSI
);

// Input Signals
input clk, rst_n;
input in_valid;
input direction;
input [12:0] addr_dram;
input [15:0] addr_sd;

// Output Signals
output reg out_valid;
output reg [7:0] out_data;

// DRAM Signals
// write address channel
output reg [31:0] AW_ADDR;
output reg AW_VALID;
input AW_READY;
// write data channel
output reg W_VALID;
output reg [63:0] W_DATA;
input W_READY;
// write response channel
input B_VALID;
input [1:0] B_RESP;
output reg B_READY;
// read address channel
output reg [31:0] AR_ADDR;
output reg AR_VALID;
input AR_READY;
// read data channel
input [63:0] R_DATA;
input R_VALID;
input [1:0] R_RESP;
output reg R_READY;

// SD Signals
input MISO;
output reg MOSI;

//==============================================//
//       parameter & integer declaration        //
//==============================================//
parameter idle=5'd0;
parameter sdreadcommand=5'd1;
parameter waitforcommand=5'd2;
parameter sdreadresponse=5'd3;
parameter waitforresptodata=5'd4;
parameter sdreaddata=5'd5;
parameter dramaddress=5'd6;
parameter dramwrite=5'd7;
parameter dramwriteout=5'd8;
parameter dramread=5'd9;
parameter sdwritecommand=5'd10;
parameter sdwriteresponse=5'd11;
parameter sdwritedata=5'd12;
parameter sdwritedataresp=5'd13;
parameter sdwriteout=5'd14;
parameter waitwritecommandresp=5'd15;
parameter busy=5'd16;
//==============================================//
//           reg & wire declaration             //
//==============================================//
reg [4:0]state,nextstate;
reg [12:0]dramaddr;
reg [15:0]sdaddr;
reg dircreg;
reg [47:0]command;
reg [7:0]countforcommand;
reg [7:0]countforsdreaddata;
reg [79:0]sdcarddata;
reg [7:0]countforout;
reg[7:0]countforresp;
reg[63:0]dramreaddata;
reg [87:0]starttokenanddataandcrc16;
reg [7:0]countforsdwrite;
reg [7:0]countfordataresp;
reg [6:0]tmpcrc7;
reg [15:0]tmpcrc16;
//==============================================//
//                  design                      //
//==============================================//
//FSM
always @(*) begin
    case (state)
        idle:begin
            if (in_valid) begin
                if (direction) nextstate=sdreadcommand;
                else nextstate=dramread;
            end
            else nextstate=idle;
        end
        sdreadcommand:begin
            if (countforcommand==8'd48) nextstate=waitforcommand;
            else nextstate=sdreadcommand;
        end
        waitforcommand:begin
            if (MISO==0) nextstate=sdreadresponse;
            else nextstate=waitforcommand;
        end
        sdreadresponse:begin
            if(MISO==1) nextstate=waitforresptodata;
            else nextstate=sdreadresponse;
        end
        waitforresptodata:begin
            if (MISO==0) nextstate=sdreaddata;
            else nextstate=waitforresptodata;
        end
        sdreaddata:begin
            if (countforsdreaddata==80) nextstate=dramaddress;
            else nextstate=sdreaddata;
        end
        dramaddress:begin
            if (AW_READY) begin
                nextstate=dramwrite;
            end
            else nextstate=dramaddress;
        end
        dramwrite:begin
            if (B_VALID) nextstate=dramwriteout;
            else nextstate=dramwrite;
        end
        dramwriteout:begin
            if (countforout==8) nextstate=idle;
            else nextstate=dramwriteout;
        end
        dramread:begin
            if (R_VALID) nextstate=sdwritecommand;
            else nextstate=dramread;
        end
        sdwritecommand:begin
            if (countforcommand==8'd48) nextstate=waitwritecommandresp;
            else nextstate=sdwritecommand;
        end
        waitwritecommandresp:begin
            if (MISO==0) nextstate=sdwriteresponse;
            else nextstate=waitwritecommandresp;
        end
        sdwriteresponse:begin
            if (countforresp==15) nextstate=sdwritedata;
            else nextstate=sdwriteresponse;
        end
        sdwritedata:begin
            if (countforsdwrite==88) nextstate=sdwritedataresp;
            else nextstate=sdwritedata;
        end
        sdwritedataresp:begin
            if (countfordataresp==8) nextstate=busy;
            else nextstate=sdwritedataresp;
        end
        busy:begin
            if (MISO==1) begin
                nextstate=sdwriteout;
            end
            else nextstate=busy;
        end
        sdwriteout:begin
            if (countforout==8) nextstate=idle;
            else nextstate=sdwriteout;
        end
        default:nextstate=idle;
    endcase
end

//state
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) state<=idle;
    else state<=nextstate;
end

//Input
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        dramaddr<=0;
        sdaddr<=0;
        dircreg<=0;
    end
    else begin
      if (in_valid) begin
        dramaddr<=addr_dram;
        sdaddr<=addr_sd;
        dircreg<=direction;
      end
    end
end

//command
always @(*) begin
    command[47:46]=2'b01;
    if (dircreg) command[45:40]=6'd17;
    else command[45:40]=6'd24;
    command[39:8]=sdaddr;
    tmpcrc7=CRC7(command[47:8]);
    command[7:1]=tmpcrc7;
    command[0]=1'b1;
end

//dramreaddata
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        dramreaddata<=0;     
    end
    else begin
        if (R_VALID) begin
            dramreaddata<=R_DATA;
        end
    end
end

//starttokenanddataandcrc16
always @(*) begin
    tmpcrc16=CRC16_CCITT(dramreaddata);
    starttokenanddataandcrc16={8'b11111110,dramreaddata,tmpcrc16};
end

//out_valid
always @(*) begin
    if ((state==dramwriteout)||(state==sdwriteout)) out_valid=1'b1;
    else out_valid=1'b0;
end

//out_data
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        out_data<=0;
        countforout<=0;
    end
    else begin
        if (nextstate==dramwriteout) begin
            out_data<=sdcarddata[79-countforout*8-:8];
            countforout<=countforout+1;
        end
        else if (nextstate==sdwriteout) begin
            out_data<=dramreaddata[63-countforout*8-:8];
            countforout<=countforout+1;
        end
        else begin
            out_data<=0;
            countforout<=0;
        end
    end
end

//MOSI
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        MOSI<=1;
        countforcommand<=0;
        countforresp<=0;
        countforsdwrite<=0;
        countfordataresp<=0;
    end
    else begin
        if ((nextstate==sdreadcommand)||(nextstate==sdwritecommand)) begin
            MOSI<=command[47-countforcommand];
            countforcommand<=countforcommand+1;
        end
        else countforcommand<=0;
        if (nextstate==waitforcommand) begin
            MOSI<=1'b1;
        end
        if (nextstate==sdwriteresponse) begin
            MOSI<=1'b1;
            countforresp<=countforresp+1;
        end
        else countforresp<=0;
        if (nextstate==sdwritedata) begin
            MOSI<=starttokenanddataandcrc16[87-countforsdwrite];
            countforsdwrite<=countforsdwrite+1;
        end
        else countforsdwrite<=0;
        if (nextstate==sdwritedataresp) begin
            MOSI<=1'b1;
            countfordataresp<=countfordataresp+1;
        end
        else countfordataresp<=0;
    end
end

//sdcarddata
always @(posedge clk or negedge rst_n)begin
    if (!rst_n) begin
        sdcarddata<=0;
        countforsdreaddata<=0;
    end
    else begin
        if (nextstate==sdreaddata) begin
            sdcarddata[80-countforsdreaddata]<=MISO;
            countforsdreaddata<=countforsdreaddata+1;
        end
        else countforsdreaddata<=0;
    end
end

//AW_ADDR and AW_VALID
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        AW_ADDR<=0;
        AW_VALID<=0;
    end
    else begin
        if (nextstate==dramaddress) begin
            AW_ADDR<=dramaddr;
            AW_VALID<=1;
        end
        else if (AW_READY) begin
            AW_ADDR<=0;
            AW_VALID<=0;
        end
        else begin
            AW_ADDR<=0;
            AW_VALID<=0;
        end
    end
end

//W_DATA and W_VALID
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        W_VALID<=0;
        W_DATA<=0;
    end
    else begin
        if (AW_READY) begin
            W_DATA<=sdcarddata[79:16];
            W_VALID<=1'b1;
        end
        if (W_READY) begin
            W_DATA<=0;
            W_VALID<=0;
        end
    end
end

//B_READY
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        B_READY<=0;
    end
    else begin
        if (AW_READY) begin
            B_READY<=1'b1;
        end
        if (B_VALID) begin
            B_READY<=1'b0;
        end        
    end
end

//AR_ADDR and AR_VALID
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        AR_ADDR<=0;
        AR_VALID<=0;
    end
    else begin
        if (in_valid&&(direction==0)) begin
            AR_ADDR<=addr_dram;
            AR_VALID<=1'b1;
        end
        if (AR_READY) begin
            AR_ADDR<=0;
            AR_VALID<=0;
        end
    end
end

//R_READY
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        R_READY<=0;
    end
    else begin
        if (AR_VALID&&AR_READY) begin
            R_READY<=1'b1;
        end
        else if (R_VALID) begin
            R_READY<=1'b0;
        end
    end
end

function automatic [6:0] CRC7;  // Return 7-bit result
    input [39:0] data;  // 40-bit data input
    reg [6:0] crc;
    integer i;
    reg data_in, data_out;
    parameter polynomial = 7'h9;  // x^7 + x^3 + 1
    begin
        crc = 7'd0;
        for (i = 0; i < 40; i = i + 1) begin
            data_in = data[39-i];
            data_out = crc[6];
            crc = crc << 1;  // Shift the CRC
            if (data_in ^ data_out) begin
                crc = crc ^ polynomial;
            end
        end
        CRC7 = crc;
    end
endfunction

function automatic [15:0] CRC16_CCITT;
    input [63:0]data;
    reg [15:0]crc;
    reg data_in,data_out;
    integer i;
    parameter polynomial=16'h1021;
    begin
        crc=16'd0;
        for (i =0 ;i<64 ;i=i+1) begin
            data_in=data[63-i];
            data_out=crc[15];
            crc=crc<<1;
            if (data_in^data_out) begin
                crc=crc^polynomial;
            end
        end
        CRC16_CCITT=crc;
    end
endfunction

endmodule
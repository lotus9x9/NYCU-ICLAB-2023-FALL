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
//   File Name   : pseudo_SD.v
//   Module Name : pseudo_SD
//   Release version : v1.0 (Release Date: Sep-2023)
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################

module pseudo_SD (
    clk,
    MOSI,
    MISO
);

input clk;
input MOSI;
output reg MISO;

parameter SD_p_r = "../00_TESTBED/SD_init.dat";
reg [63:0] SD [0:65535];
initial $readmemh(SD_p_r, SD);
reg [47:0]command;
reg [15:0]crctmp;
reg [63:0]tmpdata;
integer pat_read;
integer PAT_NUM;
integer countfor8;
initial begin
    while(1)begin
        MISO=1'b1;
        countfor8=0;
        inputcommand;
        sd123;
        if (command[45:40]==6'd17) begin 
            readresponse;
            read;
        end
        else if(command[45:40]==6'd24)begin
            writeresponse;
            write;
            sd4;
            dataresponse;
        end
    end
end

//////////////////////////////////////////////////////////////////////
// Write your own task here
//////////////////////////////////////////////////////////////////////
task inputcommand;begin
    while ((MOSI===1'b1)||(MOSI===1'bx)) begin
        @(posedge clk);
    end
    for (integer i=47;i>=1;i=i-1 ) begin
        command[i]=MOSI;
        @(posedge clk);
    end
    command[0]=MOSI;
    repeat(8*($urandom_range(0,8)))@(posedge clk);
end
endtask
task readresponse;begin
    for (integer i=0 ;i<8 ;i=i+1 ) begin
        MISO=1'b0;
        @(posedge clk);
    end
    MISO=1'b1;
    repeat(8*($urandom_range(1,32)))@(posedge clk);
end
endtask
task writeresponse;begin
    for (integer i=0 ;i<8 ;i=i+1 ) begin
        MISO=1'b0;
        @(posedge clk);
    end
    MISO=1'b1;
end
endtask

//reg [63:0]temp;
task read; begin    
    for(integer i=0;i<7;i=i+1)begin
        MISO=1'b1;
        @(posedge clk);
    end
    MISO=1'b0;
    @(posedge clk);
    //temp = SD[command[39:8]];
    for (integer i=63;i>=0 ;i=i-1 ) begin
        MISO = SD[command[39:8]][i];
        @(posedge clk);
    end
    crctmp=CRC16_CCITT(SD[command[39:8]]);
    for (integer i=15 ;i>=0 ;i=i-1 ) begin
        MISO=crctmp[i];
        @(posedge clk);
    end
end
endtask
task write;begin
    while(MOSI==1'b1)begin
        countfor8=countfor8+1;
        @(posedge clk);
    end
    if (countfor8<16) begin
        $display("SPEC SD-5 FAIL");
        $finish;
    end
    if (countfor8>264) begin
        $display("SPEC SD-5 FAIL");
        $finish;
    end
    if (countfor8%8!==0) begin
        $display("SPEC SD-5 FAIL");
        $finish;
    end
    @(posedge clk);
    for (integer i=63;i>=0 ;i=i-1) begin
        tmpdata[i]=MOSI;
        @(posedge clk);
    end
    for (integer i=15 ;i>=1 ;i=i-1 ) begin
        crctmp[i]=MOSI;
        @(posedge clk);
    end
    crctmp[0]=MOSI;
end
endtask
task dataresponse;begin
    MISO=1'b0;
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk); 
    MISO=1'b1;
    @(posedge clk);
    MISO=1'b0;
    @(posedge clk);
    MISO=1'b1;
    @(posedge clk);
    MISO=1'b0;
    repeat(8*($urandom_range(0,32)))@(posedge clk);
    SD[command[39:8]]=tmpdata;
    MISO=1'b1;
end
endtask
task sd123;begin
    if (command[46]!==1) begin
        $display("SPEC SD-1 FAIL");
        $finish;
    end
    if (command[0]!==1) begin
        $display("SPEC SD-1 FAIL");
        $finish;
    end
    if ((command[45:40]!==6'd24)&&(command[45:40]!==6'd17)) begin
        $display("SPEC SD-1 FAIL");
        $finish;
    end
    if (command[39:8]>32'd65535) begin
        $display("SPEC SD-2 FAIL");
        $finish;
    end
    if (command[7:1]!==CRC7({command[47:8]})) begin
        $display("SPEC SD-3 FAIL");
        $finish;
    end
end
endtask
task sd4;begin
    if (crctmp!==CRC16_CCITT(tmpdata)) begin
        $display(crctmp);
        $display(tmpdata);
        $display("SPEC SD-4 FAIL");
        $finish;
    end
end
endtask
//////////////////////////////////////////////////////////////////////
task YOU_FAIL_task; begin
    $display("*                              FAIL!                                    *");
    $display("*                 Error message from pseudo_SD.v                        *");
end endtask

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
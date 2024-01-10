`ifdef RTL
    `define CYCLE_TIME 40.0
`endif
`ifdef GATE
    `define CYCLE_TIME 40.0
`endif

`include "../00_TESTBED/pseudo_DRAM.v"
`include "../00_TESTBED/pseudo_SD.v"

module PATTERN(
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

/* Input for design */
output reg        clk, rst_n;
output reg        in_valid;
output reg        direction;
output reg [12:0] addr_dram;
output reg [15:0] addr_sd;

/* Output for pattern */
input        out_valid;
input  [7:0] out_data; 

// DRAM Signals
// write address channel
input [31:0] AW_ADDR;
input AW_VALID;
output AW_READY;
// write data channel
input W_VALID;
input [63:0] W_DATA;
output W_READY;
// write response channel
output B_VALID;
output [1:0] B_RESP;
input B_READY;
// read address channel
input [31:0] AR_ADDR;
input AR_VALID;
output AR_READY;
// read data channel
output [63:0] R_DATA;
output R_VALID;
output [1:0] R_RESP;
input R_READY;

// SD Signals
output MISO;
input MOSI;

real CYCLE = `CYCLE_TIME;
integer pat_read;
integer PAT_NUM;
integer total_latency,Latency;
integer i_pat;
integer waitvaltime;
integer datatransfercycle;
integer count;
reg dircreg;
reg [12:0]tmpdram;
reg [15:0]tmpsd;
reg [63:0]goldenans;
reg [7:0]tmpans;
initial clk=0;
always #(40.0/2.0) clk=~clk;
initial begin
    pat_read = $fopen("../00_TESTBED/Input.txt", "r");
    specmain1;
    i_pat = 0;
    total_latency = 0;
    $fscanf(pat_read, "%d", PAT_NUM);
    for (i_pat = 1; i_pat <= PAT_NUM; i_pat = i_pat + 1) begin
        input_task;
        specmain3;
        checkans;
        total_latency = total_latency + Latency;
        $display("PASS PATTERN NO.%4d", i_pat);
    end
    $fclose(pat_read);

    $writememh("../00_TESTBED/DRAM_final.dat", u_DRAM.DRAM);
    $writememh("../00_TESTBED/SD_final.dat", u_SD.SD);
    YOU_PASS_task;
end
//////////////////////////////////////////////////////////////////////
// Write your own task here
//////////////////////////////////////////////////////////////////////
initial begin
    while (1) begin
        if (out_valid===0) begin
            if (out_data!==0) begin
                $display("SPEC MAIN-2 FAIL");
                $finish;
            end
        end
        @(negedge clk);
    end
end

task specmain1; begin
    rst_n=1'b1;
    in_valid=1'b0;
    direction=1'bx;
    addr_dram=13'bx;
    addr_sd=16'bx;
    force clk=1'b0;
    #CYCLE; rst_n=1'b0;
    #(100);
    if ((out_valid!==0)||(out_data!==0)||(AW_ADDR!==0)||(AW_VALID!==0)||(W_VALID!==0)||(W_DATA!==0)||(B_READY!==0)||(AR_ADDR!==0)||(AR_VALID!==0)||(R_READY!==0)||(MOSI!==1)) begin
        $display("****************************************************************************");
        $display("*                                SPEC MAIN-1 FAIL                          *");
        $display("****************************************************************************");
        $finish;
    end
    rst_n=1'b1;
    #CYCLE; release clk;
end
endtask

task input_task; begin
    if (i_pat==1'd1) begin
        repeat(2)@(negedge clk);
    end
    in_valid=1'b1;
    $fscanf(pat_read,"%d %d %d",direction,addr_dram,addr_sd);
    dircreg=direction;
    tmpdram=addr_dram;
    tmpsd=addr_sd;
    if (direction) goldenans=u_SD.SD[addr_sd];
    else goldenans=u_DRAM.DRAM[addr_dram];
    @(negedge clk)
    in_valid=1'b0;
    direction=1'bx;
    addr_dram=13'bx;
    addr_sd=16'bx;
end
endtask

task specmain3; begin
    Latency=0;
    while (out_valid!==1) begin
        if (Latency==10000) begin
            $display("SPEC MAIN-3 FAIL");
            $finish;
        end
        Latency=Latency+1;
        @(negedge clk);
    end
end
endtask

task checkans;begin
    if (out_valid===1) begin
        if (dircreg) begin
            if(u_DRAM.DRAM[tmpdram]!==goldenans)begin
                $display("SPEC MAIN-6 FAIL");
                $finish;
            end
        end
        else begin
            if(u_SD.SD[tmpsd]!==goldenans)begin
                $display("SPEC MAIN-6 FAIL");
                $finish;
            end
        end
    end
    datatransfercycle=0;
    while(out_valid===1)begin
        tmpans=goldenans[63-datatransfercycle*8-:8];
        datatransfercycle=datatransfercycle+1;
        if (datatransfercycle>8) break;
        if (out_data!==tmpans) begin
            $display("SPEC MAIN-5 FAIL");
            $finish;
        end
        @(negedge clk);
    end
    if (datatransfercycle!==8) begin
        $display("SPEC MAIN-4 FAIL");
        $finish;
    end
end

endtask

//////////////////////////////////////////////////////////////////////

task YOU_PASS_task; begin
    $display("*************************************************************************");
    $display("*                         Congratulations!                              *");
    $display("*                Your execution cycles = %5d cycles          *", total_latency);
    $display("*                Your clock period = %.1f ns          *", CYCLE);
    $display("*                Total Latency = %.1f ns          *", total_latency*CYCLE);
    $display("*************************************************************************");
    $finish;
end endtask

task YOU_FAIL_task; begin
    $display("*                              FAIL!                                    *");
    $display("*                    Error message from PATTERN.v                       *");
end endtask

pseudo_DRAM u_DRAM (
    .clk(clk),
    .rst_n(rst_n),
    // write address channel
    .AW_ADDR(AW_ADDR),
    .AW_VALID(AW_VALID),
    .AW_READY(AW_READY),
    // write data channel
    .W_VALID(W_VALID),
    .W_DATA(W_DATA),
    .W_READY(W_READY),
    // write response channel
    .B_VALID(B_VALID),
    .B_RESP(B_RESP),
    .B_READY(B_READY),
    // read address channel
    .AR_ADDR(AR_ADDR),
    .AR_VALID(AR_VALID),
    .AR_READY(AR_READY),
    // read data channel
    .R_DATA(R_DATA),
    .R_VALID(R_VALID),
    .R_RESP(R_RESP),
    .R_READY(R_READY)
);

pseudo_SD u_SD (
    .clk(clk),
    .MOSI(MOSI),
    .MISO(MISO)
);

endmodule
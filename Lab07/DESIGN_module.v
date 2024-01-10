module CLK_1_MODULE (
    clk,
    rst_n,
    in_valid,
    seed_in,
    out_idle,
    out_valid,
    seed_out,

    clk1_handshake_flag1,
    clk1_handshake_flag2,
    clk1_handshake_flag3,
    clk1_handshake_flag4
);

input clk;
input rst_n;
input in_valid;
input [31:0] seed_in;
input out_idle;
output reg out_valid;
output reg [31:0] seed_out;

// You can change the input / output of the custom flag ports
input clk1_handshake_flag1;
input clk1_handshake_flag2;
output clk1_handshake_flag3;
output clk1_handshake_flag4;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) seed_out<=0;
    else if (in_valid)seed_out<=seed_in;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) out_valid<=0;
    else begin
        if (in_valid) begin
            out_valid<=1;
        end 
        else out_valid<=0;
    end
end
endmodule

module CLK_2_MODULE (
    clk,
    rst_n,
    in_valid,
    fifo_full,
    seed,
    out_valid,
    rand_num,
    busy,

    handshake_clk2_flag1,
    handshake_clk2_flag2,
    handshake_clk2_flag3,
    handshake_clk2_flag4,

    clk2_fifo_flag1,
    clk2_fifo_flag2,
    clk2_fifo_flag3,
    clk2_fifo_flag4
);

input clk;
input rst_n;
input in_valid;
input fifo_full;
input [31:0] seed;
output out_valid;
output [31:0] rand_num;
output busy;
parameter idle=0;
parameter WAIT=1;
parameter OUTPUT=2;
// You can change the input / output of the custom flag ports
input handshake_clk2_flag1;
input handshake_clk2_flag2;
output handshake_clk2_flag3;
output handshake_clk2_flag4;

input clk2_fifo_flag1;
input clk2_fifo_flag2;
output clk2_fifo_flag3;
output clk2_fifo_flag4;
reg [31:0]seedreg;
reg [31:0]datareg;
reg invalidflag1,invalidflag2,invalidflag3;
reg [31:0]a,b,c,d;
reg [1:0]state,nextstate;
reg [7:0]cnt,cntd;
NDFF_BUS_syn #(32) D1(.D(seed),.Q(seedreg),.clk(clk),.rst_n(rst_n));

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) datareg<=0;
    else begin
        if (invalidflag3) datareg<=seedreg;
        else if(state==OUTPUT&&nextstate!=WAIT) datareg<=d;
    end
end
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) cnt<=0;
    else begin
        if (state==OUTPUT&&nextstate!=WAIT) begin
            cnt<=cnt+1;
        end 
    end
end
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) cntd<=0;
    else begin
        cntd<=cnt;
    end
end
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        invalidflag1<=0;
        invalidflag2<=0;
        invalidflag3<=0;
    end
    else begin
        invalidflag1<=in_valid;
        invalidflag2<=invalidflag1;
        invalidflag3<=invalidflag2;
    end
end
always @(*) begin
    a=datareg;
    b=a^(a<<13);
    c=b^(b>>17);
    d=c^(c<<5);
end
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) state<=idle;
    else state<=nextstate;
end
always @(*) begin
    case (state)
        idle:begin
            if (invalidflag3) nextstate=OUTPUT;
            else nextstate=idle;
        end 
        WAIT:begin
            if (fifo_full) nextstate=WAIT;
            else nextstate=OUTPUT;
        end
        OUTPUT:begin
            if (cnt==255&&~fifo_full) begin
                nextstate=idle;
            end
            else if(fifo_full)nextstate=WAIT;
            else nextstate=OUTPUT;
        end
        default:nextstate=idle;
    endcase
end
assign out_valid=(state==OUTPUT&&nextstate!=WAIT);
assign rand_num=d;
assign busy=in_valid&~invalidflag1;
endmodule

module CLK_3_MODULE (
    clk,
    rst_n,
    fifo_empty,
    fifo_rdata,
    fifo_rinc,
    out_valid,
    rand_num,

    fifo_clk3_flag1,
    fifo_clk3_flag2,
    fifo_clk3_flag3,
    fifo_clk3_flag4
);

input clk;
input rst_n;
input fifo_empty;
input [31:0] fifo_rdata;
output fifo_rinc;
output reg out_valid;
output reg [31:0] rand_num;
parameter WAIT=0;
parameter read=1;
parameter out=2;
// You can change the input / output of the custom flag ports
input fifo_clk3_flag1;
input fifo_clk3_flag2;
output fifo_clk3_flag3;
output fifo_clk3_flag4;
reg [1:0]state,nextstate;
reg empty_d;
reg [7:0]cnt;
reg first,firstd1,firstd2;
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) empty_d<=0;
    else empty_d<=fifo_empty;
end
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) state<=WAIT;
    else state<=nextstate;
end
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) cnt<=0;
    else begin
        if (state==out&&firstd2) begin
            cnt<=cnt+1;
        end
    end
end
always @(*) begin
    case (state)
        WAIT:begin
            if (fifo_empty) nextstate=WAIT;
            else nextstate=read;
        end 
        read:begin
            if (fifo_empty) nextstate=WAIT;
            else nextstate=out;
        end
        out:begin
            if(cnt==255)nextstate=WAIT;
            else nextstate=out;
        end
        default:nextstate=WAIT; 
    endcase
end
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        first<=0;
    end
    else begin
        if (state==WAIT&&nextstate==read) begin
            first<=1;
        end
        else if (state==WAIT) begin
            first<=0;
        end
    end
end
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        firstd1<=0;
        firstd2<=0;
    end
    else begin
        firstd1<=first;
        firstd2<=firstd1;
    end
end
assign fifo_rinc=(state==out||state==read)&&!fifo_empty;
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        out_valid<=0;
    end
    else begin
        if (state==out&&(firstd2&&first)) out_valid<=1;
        else out_valid<=0;
    end
end
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) rand_num<=0;
    else begin
        if (state==out&&(firstd2&&first)) begin
            rand_num<=fifo_rdata;
        end
        else rand_num<=0;
    end
end
endmodule
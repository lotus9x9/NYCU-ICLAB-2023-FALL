module Handshake_syn #(parameter WIDTH=32) (
    sclk,
    dclk,
    rst_n,
    sready,
    din,
    dbusy,
    sidle,
    dvalid,
    dout,

    clk1_handshake_flag1,
    clk1_handshake_flag2,
    clk1_handshake_flag3,
    clk1_handshake_flag4,

    handshake_clk2_flag1,
    handshake_clk2_flag2,
    handshake_clk2_flag3,
    handshake_clk2_flag4
);

input sclk, dclk;
input rst_n;
input sready;
input [WIDTH-1:0] din;
input dbusy;
output sidle;
output reg dvalid;
output reg [WIDTH-1:0] dout;

// You can change the input / output of the custom flag ports
input clk1_handshake_flag1;
input clk1_handshake_flag2;
output clk1_handshake_flag3;
output clk1_handshake_flag4;

input handshake_clk2_flag1;
input handshake_clk2_flag2;
output handshake_clk2_flag3;
output handshake_clk2_flag4;

// Remember:
//   Don't modify the signal name
reg sreq;
wire dreq;
reg dack;
wire sack;
reg [WIDTH-1:0]datareg;
reg sctrl;
reg dctrl;
reg dbusyflagd1;
reg dbusyflagd2;
reg [31:0]datad2;
reg dctrld1,dctrld2;
always @(posedge dclk or negedge rst_n) begin
    if (!rst_n) dbusyflagd1<=0;
    else dbusyflagd1<=dbusy;
end
always @(posedge dclk or negedge rst_n) begin
    if (!rst_n) dbusyflagd2<=0;
    else dbusyflagd2<=dbusyflagd1;
end
always @(posedge sclk or negedge rst_n) begin
    if (!rst_n) sreq<=0;
    else if (sready) sreq<=1;
    else sreq<=0;
end
always @(posedge sclk or negedge rst_n) begin
    if (!rst_n) sctrl<=0;
    else if (sready) sctrl<=1;
    else sctrl<=0;
end
always @(posedge sclk or negedge rst_n) begin
    if (!rst_n) datareg<=0;
    else if (sctrl) datareg<=din;
end
always @(posedge dclk or negedge rst_n) begin
    if (!rst_n) dctrl<=0;
    else if (dreq) dctrl<=1;
    else dctrl<=0;
end
always @(posedge dclk or negedge rst_n) begin
    if (!rst_n) dout<=0;
    else if (dctrld2) dout<=datad2;
end
always @(posedge dclk or negedge rst_n) begin
    if (!rst_n) dack<=0;
    else begin
        if (dbusy||dbusyflagd1||dbusyflagd2) dack<=1;
        else if (!dreq) dack<=0;
    end
end

always @(posedge dclk or negedge rst_n) begin
    if (!rst_n) dvalid<=0;
    else begin
        if (dbusy||dack) dvalid<=0;
        else if(dctrld2)dvalid<=1;
    end
end
assign sidle=sreq&sack;
NDFF_syn N1(.D(sreq),.Q(dreq),.clk(dclk),.rst_n(rst_n));
NDFF_syn N2(.D(dack),.Q(sack),.clk(sclk),.rst_n(rst_n));
NDFF_BUS_syn #(32) a1(.D(datareg),.Q(datad2),.clk(dclk),.rst_n(rst_n));
always @(posedge dclk or negedge rst_n) begin
    if (!rst_n) begin
        dctrld1<=0;
        dctrld2<=0;
    end   
    else begin
        dctrld1<=dctrl;
        dctrld2<=dctrld1;
    end
end

endmodule
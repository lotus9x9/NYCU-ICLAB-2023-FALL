//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   (C) Copyright Laboratory System Integration and Silicon Implementation
//   All Right Reserved
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   ICLAB 2023 Fall
//   Lab04 Exercise		: Siamese Neural Network
//   Author     		: Hsien-Chi Peng (jhpeng2012@gmail.com)
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   File Name   : SNN.v
//   Module Name : SNN
//   Release version : V1.0 (Release Date: 2023-10)
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################

// synopsys translate_off
`ifdef RTL
	`include "GATED_OR.v"
`else
	`include "Netlist/GATED_OR_SYN.v"
`endif
// synopsys translate_on


module SNN(
    //Input Port
    clk,
    rst_n,
    in_valid,
    cg_en,
    Img,
    Kernel,
	Weight,
    Opt,

    //Output Port
    out_valid,
    out
    );


//---------------------------------------------------------------------
//   PARAMETER
//---------------------------------------------------------------------
// IEEE floating point parameter
parameter inst_sig_width = 23;
parameter inst_exp_width = 8;
parameter inst_ieee_compliance = 0;
parameter inst_arch_type = 0;
parameter inst_arch = 0;
parameter inst_faithful_round = 0;

input rst_n, clk, in_valid;
input cg_en;
input [inst_sig_width+inst_exp_width:0] Img, Kernel, Weight;
input [1:0] Opt;

output reg	out_valid;
output reg [inst_sig_width+inst_exp_width:0] out;
reg [31:0]image[0:95];
reg [31:0]weighttmp[0:3];
reg [31:0]kerneltmp[0:26];
reg [1:0]optreg;
reg [31:0]tmp1,tmp2,tmp3,tmp4,tmp5,tmp6,tmp7,tmp8,tmp9,tmp10,tmp11,tmp12,tmp13,tmp14,tmp15,tmp16,tmp17,tmp18,sum1,sum2,sum3;
reg [31:0]tmppaddingimage[0:5][0:5];

reg [31:0]equalizationpadding[0:5][0:5];
reg [31:0]equalizationpadding2[0:5][0:5];
reg [31:0]tmpkernel[0:8];
reg [31:0]convtmp3,convtmp;
reg [31:0]futuremmap1_1[0:3][0:3];
reg [31:0]futuremmap1_2[0:3][0:3];
reg [31:0]futuremmap1_3[0:3][0:3];
reg [31:0]futuremmap2_1[0:3][0:3];
reg [31:0]futuremmap2_2[0:3][0:3];
reg [31:0]futuremmap2_3[0:3][0:3];
reg [31:0]addforthree1,addforthree2,addforthree3,addthree1,addthree2,addthree3;
reg [31:0]futuremmap1[0:3][0:3];
reg [31:0]futuremmap2[0:3][0:3];
reg [31:0]tmpcmpa,tmpcmpb,max,min;
reg [31:0]normmax1,normmax2,normmin1,normmin2;
reg [31:0]xmaxsubxmin1,xmaxsubxmin2;
reg [31:0]maxpool1[0:1][0:1];
reg [31:0]maxpool2[0:1][0:1];
reg [31:0]fully1[0:3];
reg [31:0]fully2[0:3];
reg [31:0]norm1[0:3];
reg [31:0]norm2[0:3];
reg [31:0]vector1[0:3];
reg [31:0]vector2[0:3];
reg [31:0]divtmp1,divtmp2,divanswer;
reg [31:0]divtmpa,divtmpb,divans;
reg [31:0]exptmp,expout;
reg [31:0]exp1_1pos,exp1_1neg,exp1_2pos,exp1_2neg,exp1_3pos,exp1_3neg,exp1_4pos,exp1_4neg;
reg [31:0]exp2_1pos,exp2_1neg,exp2_2pos,exp2_2neg,exp2_3pos,exp2_3neg,exp2_4pos,exp2_4neg;
reg [31:0]expsubexp1_1,expsubexp1_2,expsubexp1_3,expsubexp1_4;
reg [31:0]distancetmp1,distancetmp2,distancetmp3,distancetmp4,distancetmp5;
reg [10:0]clkcnt;
reg [4:0]cnt16;
wire [31:0]one;
wire [31:0]nine;
reg [31:0]tmpcmp1,tmpcmp2,max2,min2;
reg [31:0]paddinginput[0:15];
reg [31:0]paddinginput2[0:3][0:3];
reg [31:0]equalizationadd1,equalizationadd2,equalizationadd3;
reg [31:0]equalizationadd4,equalizationadd5,equalizationadd6;
reg [31:0]equalizationadd7,equalizationadd8,equalizationadd9;
reg [31:0]equalizationsum1,equalizationsum2,equalizationsum3,equalizationsum4;
reg [31:0]beforediv9;
wire doflag;
reg gclk1,gclk2,gclk3,gclk4,gclk5,gclk6,gclk7,gclk8,gclk9,gclk10,gclk11,gclk12,gclk13,gclk14,gclk15,gclk16,gclk17,gclk18,gclk19,gclk20,gclk21,gclk22,gclk23,gclk24,gclk25,gclk26,gclk27,gclk28,gclk29,gclk30,gclk31,gclk32,gclk33,gclk34,gclk35;
wire paddingctrl;
wire cnt16ctrl;
wire dp3ctrl;
reg mapclk1,mapclk2,mapclk3,mapclk4,mapclk5,mapclk6,mapclk7,mapclk8;
reg mapclk9,mapclk10,mapclk11,mapclk12,mapclk13,mapclk14,mapclk15,mapclk16;
reg mapclk17,mapclk18,mapclk19,mapclk20,mapclk21,mapclk22,mapclk23,mapclk24,mapclk25,mapclk26,mapclk27,mapclk28;
reg tmpclk1,tmpclk2,tmpclk3;
reg expclk1,expclk2,expclk3,expclk4;
wire tmp1ctrl,tmp2ctrl,tmp3ctrl;
wire map1_1,map1_2,map1_3,map1_4;
wire map2_1,map2_2,map2_3,map2_4;
wire map3_1,map3_2,map3_3,map3_4;
wire map4_1,map4_2,map4_3,map4_4;
wire map5_1,map5_2,map5_3,map5_4;
wire map6_1,map6_2,map6_3,map6_4;
wire map7_1,map7_2,map7_3,map7_4;
wire map8_1,map8_2,map8_3,map8_4;
wire exp1,exp2,exp3,exp4;
wire sum3_1,sum3_2;
wire map1,map2;
wire paddingctrl2;
wire div9ctrl;
wire div1ctrl;
wire cmp1ctrl,cmp2ctrl;
wire maxpoolctrl;
wire fullyctrl;
wire normmaxminctrl;
wire xsubctrl;
wire normctrl;
wire div2ctrl;
wire expctrl1;
wire expctrl2;
wire expctrl3;
wire vectorctrl1,vectorctrl2;
wire distancectrl;
wire pd11,pd12,pd13,pd14,pd21,pd22,pd23,pd24;
wire k1,k2,k3;
reg gg1,gg2,gg3;
wire m2,f2,n2;
reg g1,g2,g3,g4,g5,g6,g7,g8,g9,g10,g11;
assign one=32'b00111111100000000000000000000000;
assign nine=32'b01000001000100000000000000000000;
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        clkcnt<=0;
    end
    else begin
        if (out_valid) clkcnt<=0;
        else if (clkcnt>0) clkcnt<=clkcnt+1;
        else if (in_valid) clkcnt<=1;
    end
end
//padding
assign pd11=~(clkcnt==16||clkcnt==33||clkcnt==50||clkcnt==67||clkcnt==84||clkcnt==101);
GATED_OR dfffffs(.CLOCK(clk),.SLEEP_CTRL(cg_en&&pd11),.RST_N(rst_n),.CLOCK_GATED(g1));
assign pd12=~(clkcnt==16||clkcnt==33||clkcnt==50||clkcnt==67||clkcnt==84||clkcnt==101);
GATED_OR dffffffs(.CLOCK(clk),.SLEEP_CTRL(cg_en&&pd12),.RST_N(rst_n),.CLOCK_GATED(g2));
assign pd13=~(clkcnt==16||clkcnt==33||clkcnt==50||clkcnt==67||clkcnt==84||clkcnt==101);
GATED_OR dfssffffs(.CLOCK(clk),.SLEEP_CTRL(cg_en&&pd13),.RST_N(rst_n),.CLOCK_GATED(g3));
assign pd14=~(clkcnt==16||clkcnt==33||clkcnt==50||clkcnt==67||clkcnt==84||clkcnt==101);
GATED_OR dffgdsfffs(.CLOCK(clk),.SLEEP_CTRL(cg_en&&pd14),.RST_N(rst_n),.CLOCK_GATED(g4));
always @(posedge g1 or negedge rst_n) begin
    if (!rst_n) begin
        paddinginput[0]<=0;
        paddinginput[1]<=0;
        paddinginput[2]<=0;
        paddinginput[3]<=0;
    end
    else begin
        case (clkcnt)
            16:begin
                paddinginput[0]<=image[0];
                paddinginput[1]<=image[1];
                paddinginput[2]<=image[2];
                paddinginput[3]<=image[3];
            end 
            33:begin
                paddinginput[0]<=image[16];
                paddinginput[1]<=image[17];
                paddinginput[2]<=image[18];
                paddinginput[3]<=image[19];
            end
            50:begin
                paddinginput[0]<=image[32];
                paddinginput[1]<=image[33];
                paddinginput[2]<=image[34];
                paddinginput[3]<=image[35];
            end
            67:begin
                paddinginput[0]<=image[48];
                paddinginput[1]<=image[49];
                paddinginput[2]<=image[50];
                paddinginput[3]<=image[51];
            end
            84:begin
                paddinginput[0]<=image[64];
                paddinginput[1]<=image[65];
                paddinginput[2]<=image[66];
                paddinginput[3]<=image[67];
            end
            101:begin
                paddinginput[0]<=image[80];
                paddinginput[1]<=image[81];
                paddinginput[2]<=image[82];
                paddinginput[3]<=image[83];
            end
        endcase
    end
end
always @(posedge g2 or negedge rst_n) begin
    if (!rst_n) begin
        paddinginput[4]<=0;
        paddinginput[5]<=0;
        paddinginput[6]<=0;
        paddinginput[7]<=0;
    end
    else begin
        case (clkcnt)
            16:begin
                paddinginput[4]<=image[4];
                paddinginput[5]<=image[5];
                paddinginput[6]<=image[6];
                paddinginput[7]<=image[7];
            end 
            33:begin
                paddinginput[4]<=image[20];
                paddinginput[5]<=image[21];
                paddinginput[6]<=image[22];
                paddinginput[7]<=image[23];
            end
            50:begin
                paddinginput[4]<=image[36];
                paddinginput[5]<=image[37];
                paddinginput[6]<=image[38];
                paddinginput[7]<=image[39];
            end
            67:begin
                paddinginput[4]<=image[52];
                paddinginput[5]<=image[53];
                paddinginput[6]<=image[54];
                paddinginput[7]<=image[55];
            end
            84:begin
                paddinginput[4]<=image[68];
                paddinginput[5]<=image[69];
                paddinginput[6]<=image[70];
                paddinginput[7]<=image[71];
            end
            101:begin
                paddinginput[4]<=image[84];
                paddinginput[5]<=image[85];
                paddinginput[6]<=image[86];
                paddinginput[7]<=image[87];
            end
        endcase
    end
end
always @(posedge g3 or negedge rst_n) begin
    if (!rst_n) begin
        paddinginput[8]<=0;
        paddinginput[9]<=0;
        paddinginput[10]<=0;
        paddinginput[11]<=0;
    end
    else begin
        case (clkcnt)
            16:begin
                paddinginput[8]<=image[8];
                paddinginput[9]<=image[9];
                paddinginput[10]<=image[10];
                paddinginput[11]<=image[11];
            end 
            33:begin
                paddinginput[8]<=image[24];
                paddinginput[9]<=image[25];
                paddinginput[10]<=image[26];
                paddinginput[11]<=image[27];
            end
            50:begin
                paddinginput[8]<=image[40];
                paddinginput[9]<=image[41];
                paddinginput[10]<=image[42];
                paddinginput[11]<=image[43];
            end
            67:begin
                paddinginput[8]<=image[56];
                paddinginput[9]<=image[57];
                paddinginput[10]<=image[58];
                paddinginput[11]<=image[59];
            end
            84:begin
                paddinginput[8]<=image[72];
                paddinginput[9]<=image[73];
                paddinginput[10]<=image[74];
                paddinginput[11]<=image[75];
            end
            101:begin
                paddinginput[8]<=image[88];
                paddinginput[9]<=image[89];
                paddinginput[10]<=image[90];
                paddinginput[11]<=image[91];
            end
        endcase
    end
end
always @(posedge g4 or negedge rst_n) begin
    if (!rst_n) begin
        paddinginput[12]<=0;
        paddinginput[13]<=0;
        paddinginput[14]<=0;
        paddinginput[15]<=0;
    end
    else begin
        case (clkcnt)
            16:begin
                paddinginput[12]<=image[12];
                paddinginput[13]<=image[13];
                paddinginput[14]<=image[14];
                paddinginput[15]<=image[15];
            end 
            33:begin
                paddinginput[12]<=image[28];
                paddinginput[13]<=image[29];
                paddinginput[14]<=image[30];
                paddinginput[15]<=image[31];
            end
            50:begin
                paddinginput[12]<=image[44];
                paddinginput[13]<=image[45];
                paddinginput[14]<=image[46];
                paddinginput[15]<=image[47];
            end
            67:begin
                paddinginput[12]<=image[60];
                paddinginput[13]<=image[61];
                paddinginput[14]<=image[62];
                paddinginput[15]<=image[63];
            end
            84:begin
                paddinginput[12]<=image[76];
                paddinginput[13]<=image[77];
                paddinginput[14]<=image[78];
                paddinginput[15]<=image[79];
            end
            101:begin
                paddinginput[12]<=image[92];
                paddinginput[13]<=image[93];
                paddinginput[14]<=image[94];
                paddinginput[15]<=image[95];
            end
        endcase
    end
end
padding p1(.image4x4(paddinginput),.opt_0(optreg[0]),.image6x6(tmppaddingimage));
//Convolution
assign k1=~(clkcnt==16||clkcnt==33||clkcnt==50||clkcnt==67||clkcnt==84||clkcnt==101);
GATED_OR dffsffffs(.CLOCK(clk),.SLEEP_CTRL(cg_en&&k1),.RST_N(rst_n),.CLOCK_GATED(gg1));
assign k2=~(clkcnt==16||clkcnt==33||clkcnt==50||clkcnt==67||clkcnt==84||clkcnt==101);
GATED_OR dsfdffffffffs(.CLOCK(clk),.SLEEP_CTRL(cg_en&&k2),.RST_N(rst_n),.CLOCK_GATED(gg2));
assign k3=~(clkcnt==16||clkcnt==33||clkcnt==50||clkcnt==67||clkcnt==84||clkcnt==101);
GATED_OR dfssffsdfffs(.CLOCK(clk),.SLEEP_CTRL(cg_en&&k3),.RST_N(rst_n),.CLOCK_GATED(gg3));
always @(posedge gg1 or negedge rst_n) begin
    if (!rst_n) begin
        tmpkernel[0]<=0;
        tmpkernel[1]<=0;
        tmpkernel[2]<=0;
    end
    else begin
        case (clkcnt)
            8'd16:begin
                tmpkernel[0]<=kerneltmp[0];
                tmpkernel[1]<=kerneltmp[1];
                tmpkernel[2]<=kerneltmp[2];
            end
            8'd33:begin
                tmpkernel[0]<=kerneltmp[9];
                tmpkernel[1]<=kerneltmp[10];
                tmpkernel[2]<=kerneltmp[11];
            end
            8'd50:begin
                tmpkernel[0]<=kerneltmp[18];
                tmpkernel[1]<=kerneltmp[19];
                tmpkernel[2]<=kerneltmp[20];
            end
            8'd67:begin
                tmpkernel[0]<=kerneltmp[0];
                tmpkernel[1]<=kerneltmp[1];
                tmpkernel[2]<=kerneltmp[2];
            end
            8'd84:begin
                tmpkernel[0]<=kerneltmp[9];
                tmpkernel[1]<=kerneltmp[10];
                tmpkernel[2]<=kerneltmp[11];
            end
            8'd101:begin
                tmpkernel[0]<=kerneltmp[18];
                tmpkernel[1]<=kerneltmp[19];
                tmpkernel[2]<=kerneltmp[20];
            end
        endcase
    end
end
always @(posedge gg2 or negedge rst_n) begin
    if (!rst_n) begin
        tmpkernel[3]<=0;
        tmpkernel[4]<=0;
        tmpkernel[5]<=0;
    end
    else begin
        case (clkcnt)
            8'd16:begin
                tmpkernel[3]<=kerneltmp[3];
                tmpkernel[4]<=kerneltmp[4];
                tmpkernel[5]<=kerneltmp[5];
            end
            8'd33:begin
                tmpkernel[3]<=kerneltmp[12];
                tmpkernel[4]<=kerneltmp[13];
                tmpkernel[5]<=kerneltmp[14];
            end
            8'd50:begin
                tmpkernel[3]<=kerneltmp[21];
                tmpkernel[4]<=kerneltmp[22];
                tmpkernel[5]<=kerneltmp[23];
            end
            8'd67:begin
                tmpkernel[3]<=kerneltmp[3];
                tmpkernel[4]<=kerneltmp[4];
                tmpkernel[5]<=kerneltmp[5];
            end
            8'd84:begin
                tmpkernel[3]<=kerneltmp[12];
                tmpkernel[4]<=kerneltmp[13];
                tmpkernel[5]<=kerneltmp[14];
            end
            8'd101:begin
                tmpkernel[3]<=kerneltmp[21];
                tmpkernel[4]<=kerneltmp[22];
                tmpkernel[5]<=kerneltmp[23];
            end
        endcase
    end
end
always @(posedge gg3 or negedge rst_n) begin
    if (!rst_n) begin
        tmpkernel[6]<=0;
        tmpkernel[7]<=0;
        tmpkernel[8]<=0;
    end
    else begin
        case (clkcnt)
            8'd16:begin
                tmpkernel[6]<=kerneltmp[6];
                tmpkernel[7]<=kerneltmp[7];
                tmpkernel[8]<=kerneltmp[8];
            end
            8'd33:begin
                tmpkernel[6]<=kerneltmp[15];
                tmpkernel[7]<=kerneltmp[16];
                tmpkernel[8]<=kerneltmp[17];
            end
            8'd50:begin
                tmpkernel[6]<=kerneltmp[24];
                tmpkernel[7]<=kerneltmp[25];
                tmpkernel[8]<=kerneltmp[26];
            end
            8'd67:begin
                tmpkernel[6]<=kerneltmp[6];
                tmpkernel[7]<=kerneltmp[7];
                tmpkernel[8]<=kerneltmp[8];
            end
            8'd84:begin
                tmpkernel[6]<=kerneltmp[15];
                tmpkernel[7]<=kerneltmp[16];
                tmpkernel[8]<=kerneltmp[17];
            end
            8'd101:begin
                tmpkernel[6]<=kerneltmp[24];
                tmpkernel[7]<=kerneltmp[25];
                tmpkernel[8]<=kerneltmp[26];
            end
        endcase
    end
end
assign cnt16ctrl=~(clkcnt>16&&clkcnt<=120);
GATED_OR dfsdffs(.CLOCK(clk),.SLEEP_CTRL(cg_en&&cnt16ctrl),.RST_N(rst_n),.CLOCK_GATED(gclk1));
always @(posedge gclk1 or negedge rst_n) begin
    if (!rst_n) begin
        cnt16<=0;
    end
    else begin
        if (clkcnt>16&&clkcnt<=118) begin
            if (cnt16==16) begin
                cnt16<=0;
            end
            else cnt16<=cnt16+1;
        end
        else cnt16<=0;
    end
end
assign tmp1ctrl=~((clkcnt>=0&clkcnt<=119)||clkcnt==143||clkcnt==144);
GATED_OR dfs(.CLOCK(clk),.SLEEP_CTRL(cg_en&&tmp1ctrl),.RST_N(rst_n),.CLOCK_GATED(tmpclk1));
assign tmp2ctrl=~((clkcnt>=0&clkcnt<=119)||clkcnt==143||clkcnt==144);
GATED_OR dfsf(.CLOCK(clk),.SLEEP_CTRL(cg_en&&tmp2ctrl),.RST_N(rst_n),.CLOCK_GATED(tmpclk2));
assign tmp3ctrl=~((clkcnt>=0&clkcnt<=117));
GATED_OR dfdsfsf(.CLOCK(clk),.SLEEP_CTRL(cg_en&&tmp3ctrl),.RST_N(rst_n),.CLOCK_GATED(tmpclk3));
always @(posedge tmpclk1 or negedge rst_n) begin
    if (!rst_n) begin
        tmp1<=0;
        tmp2<=0;
        tmp3<=0;
        tmp4<=0;
        tmp5<=0;
        tmp6<=0;
    end
    else begin
        if (clkcnt>=0&&clkcnt<=117) begin
            case (cnt16)
                5'd0:begin
                    tmp1<=tmppaddingimage[0][0];
                    tmp2<=tmpkernel[0];
                    tmp3<=tmppaddingimage[0][1];
                    tmp4<=tmpkernel[1];
                    tmp5<=tmppaddingimage[0][2];
                    tmp6<=tmpkernel[2];
                end
                5'd1:begin
                    tmp1<=tmppaddingimage[0][1];
                    tmp2<=tmpkernel[0];
                    tmp3<=tmppaddingimage[0][2];
                    tmp4<=tmpkernel[1];
                    tmp5<=tmppaddingimage[0][3];
                    tmp6<=tmpkernel[2];
                end
                5'd2:begin
                    tmp1<=tmppaddingimage[0][2];
                    tmp2<=tmpkernel[0];
                    tmp3<=tmppaddingimage[0][3];
                    tmp4<=tmpkernel[1];
                    tmp5<=tmppaddingimage[0][4];
                    tmp6<=tmpkernel[2];
                end
                5'd3:begin
                    tmp1<=tmppaddingimage[0][3];
                    tmp2<=tmpkernel[0];
                    tmp3<=tmppaddingimage[0][4];
                    tmp4<=tmpkernel[1];
                    tmp5<=tmppaddingimage[0][5];
                    tmp6<=tmpkernel[2];
                end
                5'd4:begin
                    tmp1<=tmppaddingimage[1][0];
                    tmp2<=tmpkernel[0];
                    tmp3<=tmppaddingimage[1][1];
                    tmp4<=tmpkernel[1];
                    tmp5<=tmppaddingimage[1][2];
                    tmp6<=tmpkernel[2];
                end
                5'd5:begin
                    tmp1<=tmppaddingimage[1][1];
                    tmp2<=tmpkernel[0];
                    tmp3<=tmppaddingimage[1][2];
                    tmp4<=tmpkernel[1];
                    tmp5<=tmppaddingimage[1][3];
                    tmp6<=tmpkernel[2];
                end
                5'd6:begin
                    tmp1<=tmppaddingimage[1][2];
                    tmp2<=tmpkernel[0];
                    tmp3<=tmppaddingimage[1][3];
                    tmp4<=tmpkernel[1];
                    tmp5<=tmppaddingimage[1][4];
                    tmp6<=tmpkernel[2];
                end
                5'd7:begin
                    tmp1<=tmppaddingimage[1][3];
                    tmp2<=tmpkernel[0];
                    tmp3<=tmppaddingimage[1][4];
                    tmp4<=tmpkernel[1];
                    tmp5<=tmppaddingimage[1][5];
                    tmp6<=tmpkernel[2];
                end
                5'd8:begin
                    tmp1<=tmppaddingimage[2][0];
                    tmp2<=tmpkernel[0];
                    tmp3<=tmppaddingimage[2][1];
                    tmp4<=tmpkernel[1];
                    tmp5<=tmppaddingimage[2][2];
                    tmp6<=tmpkernel[2];
                end
                5'd9:begin
                    tmp1<=tmppaddingimage[2][1];
                    tmp2<=tmpkernel[0];
                    tmp3<=tmppaddingimage[2][2];
                    tmp4<=tmpkernel[1];
                    tmp5<=tmppaddingimage[2][3];
                    tmp6<=tmpkernel[2];
                end
                5'd10:begin
                    tmp1<=tmppaddingimage[2][2];
                    tmp2<=tmpkernel[0];
                    tmp3<=tmppaddingimage[2][3];
                    tmp4<=tmpkernel[1];
                    tmp5<=tmppaddingimage[2][4];
                    tmp6<=tmpkernel[2];
                end
                5'd11:begin
                    tmp1<=tmppaddingimage[2][3];
                    tmp2<=tmpkernel[0];
                    tmp3<=tmppaddingimage[2][4];
                    tmp4<=tmpkernel[1];
                    tmp5<=tmppaddingimage[2][5];
                    tmp6<=tmpkernel[2];
                end
                5'd12:begin
                    tmp1<=tmppaddingimage[3][0];
                    tmp2<=tmpkernel[0];
                    tmp3<=tmppaddingimage[3][1];
                    tmp4<=tmpkernel[1];
                    tmp5<=tmppaddingimage[3][2];
                    tmp6<=tmpkernel[2];
                end
                5'd13:begin
                    tmp1<=tmppaddingimage[3][1];
                    tmp2<=tmpkernel[0];
                    tmp3<=tmppaddingimage[3][2];
                    tmp4<=tmpkernel[1];
                    tmp5<=tmppaddingimage[3][3];
                    tmp6<=tmpkernel[2];
                end
                5'd14:begin
                    tmp1<=tmppaddingimage[3][2];
                    tmp2<=tmpkernel[0];
                    tmp3<=tmppaddingimage[3][3];
                    tmp4<=tmpkernel[1];
                    tmp5<=tmppaddingimage[3][4];
                    tmp6<=tmpkernel[2];
                end
                5'd15:begin
                    tmp1<=tmppaddingimage[3][3];
                    tmp2<=tmpkernel[0];
                    tmp3<=tmppaddingimage[3][4];
                    tmp4<=tmpkernel[1];
                    tmp5<=tmppaddingimage[3][5];
                    tmp6<=tmpkernel[2];
                end
            endcase
        end
        else begin
            case(clkcnt)
                8'd118:begin
                    tmp1<=maxpool1[0][0];
                    tmp2<=weighttmp[0];
                    tmp3<=maxpool1[0][1];
                    tmp4<=weighttmp[2];
                    tmp5<=0;
                    tmp6<=0;
                end
                8'd119:begin
                    tmp1<=maxpool1[1][0];
                    tmp2<=weighttmp[0];
                    tmp3<=maxpool1[1][1];
                    tmp4<=weighttmp[2];
                    tmp5<=0;
                    tmp6<=0;
                end
                8'd143:begin
                    tmp1<=maxpool2[0][0];
                    tmp2<=weighttmp[0];
                    tmp3<=maxpool2[0][1];
                    tmp4<=weighttmp[2];
                    tmp5<=0;
                    tmp6<=0;
                end
                8'd144:begin
                    tmp1<=maxpool2[1][0];
                    tmp2<=weighttmp[0];
                    tmp3<=maxpool2[1][1];
                    tmp4<=weighttmp[2];
                    tmp5<=0;
                    tmp6<=0;
                end
            endcase
        end
    end
end
always @(posedge tmpclk2 or negedge rst_n) begin
    if (!rst_n) begin
        tmp7<=0;
        tmp8<=0;
        tmp9<=0;
        tmp10<=0;
        tmp11<=0;
        tmp12<=0;
    end
    else begin
        if (clkcnt>=0&&clkcnt<=117) begin
            case (cnt16)
                5'd0:begin
                    tmp7<=tmppaddingimage[1][0];
                    tmp8<=tmpkernel[3];
                    tmp9<=tmppaddingimage[1][1];
                    tmp10<=tmpkernel[4];
                    tmp11<=tmppaddingimage[1][2];
                    tmp12<=tmpkernel[5];
                end
                5'd1:begin
                    tmp7<=tmppaddingimage[1][1];
                    tmp8<=tmpkernel[3];
                    tmp9<=tmppaddingimage[1][2];
                    tmp10<=tmpkernel[4];
                    tmp11<=tmppaddingimage[1][3];
                    tmp12<=tmpkernel[5];
                end
                5'd2:begin
                    tmp7<=tmppaddingimage[1][2];
                    tmp8<=tmpkernel[3];
                    tmp9<=tmppaddingimage[1][3];
                    tmp10<=tmpkernel[4];
                    tmp11<=tmppaddingimage[1][4];
                    tmp12<=tmpkernel[5];
                end
                5'd3:begin
                    tmp7<=tmppaddingimage[1][3];
                    tmp8<=tmpkernel[3];
                    tmp9<=tmppaddingimage[1][4];
                    tmp10<=tmpkernel[4];
                    tmp11<=tmppaddingimage[1][5];
                    tmp12<=tmpkernel[5];
                end
                5'd4:begin
                    tmp7<=tmppaddingimage[2][0];
                    tmp8<=tmpkernel[3];
                    tmp9<=tmppaddingimage[2][1];
                    tmp10<=tmpkernel[4];
                    tmp11<=tmppaddingimage[2][2];
                    tmp12<=tmpkernel[5];
                end
                5'd5:begin
                    tmp7<=tmppaddingimage[2][1];
                    tmp8<=tmpkernel[3];
                    tmp9<=tmppaddingimage[2][2];
                    tmp10<=tmpkernel[4];
                    tmp11<=tmppaddingimage[2][3];
                    tmp12<=tmpkernel[5];
                end
                5'd6:begin
                    tmp7<=tmppaddingimage[2][2];
                    tmp8<=tmpkernel[3];
                    tmp9<=tmppaddingimage[2][3];
                    tmp10<=tmpkernel[4];
                    tmp11<=tmppaddingimage[2][4];
                    tmp12<=tmpkernel[5];
                end
                5'd7:begin
                    tmp7<=tmppaddingimage[2][3];
                    tmp8<=tmpkernel[3];
                    tmp9<=tmppaddingimage[2][4];
                    tmp10<=tmpkernel[4];
                    tmp11<=tmppaddingimage[2][5];
                    tmp12<=tmpkernel[5];
                end
                5'd8:begin
                    tmp7<=tmppaddingimage[3][0];
                    tmp8<=tmpkernel[3];
                    tmp9<=tmppaddingimage[3][1];
                    tmp10<=tmpkernel[4];
                    tmp11<=tmppaddingimage[3][2];
                    tmp12<=tmpkernel[5];
                end
                5'd9:begin
                    tmp7<=tmppaddingimage[3][1];
                    tmp8<=tmpkernel[3];
                    tmp9<=tmppaddingimage[3][2];
                    tmp10<=tmpkernel[4];
                    tmp11<=tmppaddingimage[3][3];
                    tmp12<=tmpkernel[5];
                end
                5'd10:begin
                    tmp7<=tmppaddingimage[3][2];
                    tmp8<=tmpkernel[3];
                    tmp9<=tmppaddingimage[3][3];
                    tmp10<=tmpkernel[4];
                    tmp11<=tmppaddingimage[3][4];
                    tmp12<=tmpkernel[5];
                end
                5'd11:begin
                    tmp7<=tmppaddingimage[3][3];
                    tmp8<=tmpkernel[3];
                    tmp9<=tmppaddingimage[3][4];
                    tmp10<=tmpkernel[4];
                    tmp11<=tmppaddingimage[3][5];
                    tmp12<=tmpkernel[5];
                end
                5'd12:begin
                    tmp7<=tmppaddingimage[4][0];
                    tmp8<=tmpkernel[3];
                    tmp9<=tmppaddingimage[4][1];
                    tmp10<=tmpkernel[4];
                    tmp11<=tmppaddingimage[4][2];
                    tmp12<=tmpkernel[5];
                end
                5'd13:begin
                    tmp7<=tmppaddingimage[4][1];
                    tmp8<=tmpkernel[3];
                    tmp9<=tmppaddingimage[4][2];
                    tmp10<=tmpkernel[4];
                    tmp11<=tmppaddingimage[4][3];
                    tmp12<=tmpkernel[5];
                end
                5'd14:begin
                    tmp7<=tmppaddingimage[4][2];
                    tmp8<=tmpkernel[3];
                    tmp9<=tmppaddingimage[4][3];
                    tmp10<=tmpkernel[4];
                    tmp11<=tmppaddingimage[4][4];
                    tmp12<=tmpkernel[5];
                end
                5'd15:begin
                    tmp7<=tmppaddingimage[4][3];
                    tmp8<=tmpkernel[3];
                    tmp9<=tmppaddingimage[4][4];
                    tmp10<=tmpkernel[4];
                    tmp11<=tmppaddingimage[4][5];
                    tmp12<=tmpkernel[5];
                end
            endcase
        end
        else begin
            case(clkcnt)
                8'd118:begin
                    tmp7<=maxpool1[0][0];
                    tmp8<=weighttmp[1];
                    tmp9<=maxpool1[0][1];
                    tmp10<=weighttmp[3];
                    tmp11<=0;
                    tmp12<=0;
                end
                8'd119:begin
                    tmp7<=maxpool1[1][0];
                    tmp8<=weighttmp[1];
                    tmp9<=maxpool1[1][1];
                    tmp10<=weighttmp[3];
                    tmp11<=0;
                    tmp12<=0;
                end
                8'd143:begin
                    tmp7<=maxpool2[0][0];
                    tmp8<=weighttmp[1];
                    tmp9<=maxpool2[0][1];
                    tmp10<=weighttmp[3];
                    tmp11<=0;
                    tmp12<=0;
                end
                8'd144:begin
                    tmp7<=maxpool2[1][0];
                    tmp8<=weighttmp[1];
                    tmp9<=maxpool2[1][1];
                    tmp10<=weighttmp[3];
                    tmp11<=0;
                    tmp12<=0;
                end
            endcase
        end
    end
end
always @(posedge tmpclk3 or negedge rst_n) begin
    if (!rst_n) begin
        tmp13<=0;
        tmp14<=0;
        tmp15<=0;
        tmp16<=0;
        tmp17<=0;
        tmp18<=0;
    end
    else begin
        if (clkcnt>=0&&clkcnt<=117) begin
            case (cnt16)
                5'd0:begin
                    tmp13<=tmppaddingimage[2][0];
                    tmp14<=tmpkernel[6];
                    tmp15<=tmppaddingimage[2][1];
                    tmp16<=tmpkernel[7];
                    tmp17<=tmppaddingimage[2][2];
                    tmp18<=tmpkernel[8];
                end
                5'd1:begin
                    tmp13<=tmppaddingimage[2][1];
                    tmp14<=tmpkernel[6];
                    tmp15<=tmppaddingimage[2][2];
                    tmp16<=tmpkernel[7];
                    tmp17<=tmppaddingimage[2][3];
                    tmp18<=tmpkernel[8];
                end
                5'd2:begin
                    tmp13<=tmppaddingimage[2][2];
                    tmp14<=tmpkernel[6];
                    tmp15<=tmppaddingimage[2][3];
                    tmp16<=tmpkernel[7];
                    tmp17<=tmppaddingimage[2][4];
                    tmp18<=tmpkernel[8];
                end
                5'd3:begin
                    tmp13<=tmppaddingimage[2][3];
                    tmp14<=tmpkernel[6];
                    tmp15<=tmppaddingimage[2][4];
                    tmp16<=tmpkernel[7];
                    tmp17<=tmppaddingimage[2][5];
                    tmp18<=tmpkernel[8];
                end
                5'd4:begin
                    tmp13<=tmppaddingimage[3][0];
                    tmp14<=tmpkernel[6];
                    tmp15<=tmppaddingimage[3][1];
                    tmp16<=tmpkernel[7];
                    tmp17<=tmppaddingimage[3][2];
                    tmp18<=tmpkernel[8];
                end
                5'd5:begin
                    tmp13<=tmppaddingimage[3][1];
                    tmp14<=tmpkernel[6];
                    tmp15<=tmppaddingimage[3][2];
                    tmp16<=tmpkernel[7];
                    tmp17<=tmppaddingimage[3][3];
                    tmp18<=tmpkernel[8];
                end
                5'd6:begin
                    tmp13<=tmppaddingimage[3][2];
                    tmp14<=tmpkernel[6];
                    tmp15<=tmppaddingimage[3][3];
                    tmp16<=tmpkernel[7];
                    tmp17<=tmppaddingimage[3][4];
                    tmp18<=tmpkernel[8];
                end
                5'd7:begin
                    tmp13<=tmppaddingimage[3][3];
                    tmp14<=tmpkernel[6];
                    tmp15<=tmppaddingimage[3][4];
                    tmp16<=tmpkernel[7];
                    tmp17<=tmppaddingimage[3][5];
                    tmp18<=tmpkernel[8];
                end
                5'd8:begin
                    tmp13<=tmppaddingimage[4][0];
                    tmp14<=tmpkernel[6];
                    tmp15<=tmppaddingimage[4][1];
                    tmp16<=tmpkernel[7];
                    tmp17<=tmppaddingimage[4][2];
                    tmp18<=tmpkernel[8];
                end
                5'd9:begin
                    tmp13<=tmppaddingimage[4][1];
                    tmp14<=tmpkernel[6];
                    tmp15<=tmppaddingimage[4][2];
                    tmp16<=tmpkernel[7];
                    tmp17<=tmppaddingimage[4][3];
                    tmp18<=tmpkernel[8];
                end
                5'd10:begin
                    tmp13<=tmppaddingimage[4][2];
                    tmp14<=tmpkernel[6];
                    tmp15<=tmppaddingimage[4][3];
                    tmp16<=tmpkernel[7];
                    tmp17<=tmppaddingimage[4][4];
                    tmp18<=tmpkernel[8];
                end
                5'd11:begin
                    tmp13<=tmppaddingimage[4][3];
                    tmp14<=tmpkernel[6];
                    tmp15<=tmppaddingimage[4][4];
                    tmp16<=tmpkernel[7];
                    tmp17<=tmppaddingimage[4][5];
                    tmp18<=tmpkernel[8];
                end
                5'd12:begin
                    tmp13<=tmppaddingimage[5][0];
                    tmp14<=tmpkernel[6];
                    tmp15<=tmppaddingimage[5][1];
                    tmp16<=tmpkernel[7];
                    tmp17<=tmppaddingimage[5][2];
                    tmp18<=tmpkernel[8];
                end
                5'd13:begin
                    tmp13<=tmppaddingimage[5][1];
                    tmp14<=tmpkernel[6];
                    tmp15<=tmppaddingimage[5][2];
                    tmp16<=tmpkernel[7];
                    tmp17<=tmppaddingimage[5][3];
                    tmp18<=tmpkernel[8];
                end
                5'd14:begin
                    tmp13<=tmppaddingimage[5][2];
                    tmp14<=tmpkernel[6];
                    tmp15<=tmppaddingimage[5][3];
                    tmp16<=tmpkernel[7];
                    tmp17<=tmppaddingimage[5][4];
                    tmp18<=tmpkernel[8];
                end
                5'd15:begin
                    tmp13<=tmppaddingimage[5][3];
                    tmp14<=tmpkernel[6];
                    tmp15<=tmppaddingimage[5][4];
                    tmp16<=tmpkernel[7];
                    tmp17<=tmppaddingimage[5][5];
                    tmp18<=tmpkernel[8];
                end
            endcase
        end
    end
end

DW_fp_dp3 #(inst_sig_width,inst_exp_width,inst_ieee_compliance,inst_arch_type) m1(.a(tmp1),.b(tmp2),.c(tmp3),.d(tmp4),.e(tmp5),.f(tmp6),.rnd(3'b0),.z(sum1));
DW_fp_dp3 #(inst_sig_width,inst_exp_width,inst_ieee_compliance,inst_arch_type) mdd2(.a(tmp7),.b(tmp8),.c(tmp9),.d(tmp10),.e(tmp11),.f(tmp12),.rnd(3'b0),.z(sum2));
DW_fp_dp3 #(inst_sig_width,inst_exp_width,inst_ieee_compliance,inst_arch_type) m3(.a(tmp13),.b(tmp14),.c(tmp15),.d(tmp16),.e(tmp17),.f(tmp18),.rnd(3'b0),.z(sum3));
assign map1_1=~(clkcnt>=19&&clkcnt<=22);
GATED_OR map1_1clk(.CLOCK(clk),.SLEEP_CTRL(cg_en&&map1_1),.RST_N(rst_n),.CLOCK_GATED(gclk4));
assign map1_2=~(clkcnt>=23&&clkcnt<=26);
GATED_OR map1_2clk(.CLOCK(clk),.SLEEP_CTRL(cg_en&&map1_2),.RST_N(rst_n),.CLOCK_GATED(gclk5));
assign map1_3=~(clkcnt>=27&&clkcnt<=30);
GATED_OR map1_3clk(.CLOCK(clk),.SLEEP_CTRL(cg_en&&map1_3),.RST_N(rst_n),.CLOCK_GATED(gclk6));
assign map1_4=~(clkcnt>=31&&clkcnt<=34);
GATED_OR map1_4clk(.CLOCK(clk),.SLEEP_CTRL(cg_en&&map1_4),.RST_N(rst_n),.CLOCK_GATED(gclk7));
always @(posedge gclk4 or negedge rst_n) begin
    if (!rst_n) begin
        futuremmap1_1[0][0]<=0;
        futuremmap1_1[0][1]<=0;
        futuremmap1_1[0][2]<=0;
        futuremmap1_1[0][3]<=0;
    end
    else begin
        case (clkcnt)
            8'd19:futuremmap1_1[0][0]<=convtmp3;
            8'd20:futuremmap1_1[0][1]<=convtmp3;
            8'd21:futuremmap1_1[0][2]<=convtmp3;
            8'd22:futuremmap1_1[0][3]<=convtmp3;
        endcase
    end
end
always @(posedge gclk5 or negedge rst_n) begin
    if (!rst_n) begin
        futuremmap1_1[1][0]<=0;
        futuremmap1_1[1][1]<=0;
        futuremmap1_1[1][2]<=0;
        futuremmap1_1[1][3]<=0;
    end
    else begin
        case (clkcnt)
            8'd23:futuremmap1_1[1][0]<=convtmp3;
            8'd24:futuremmap1_1[1][1]<=convtmp3; 
            8'd25:futuremmap1_1[1][2]<=convtmp3;
            8'd26:futuremmap1_1[1][3]<=convtmp3;
        endcase
    end
end
always @(posedge gclk6 or negedge rst_n) begin
    if (!rst_n) begin
        futuremmap1_1[2][0]<=0;
        futuremmap1_1[2][1]<=0;
        futuremmap1_1[2][2]<=0;
        futuremmap1_1[2][3]<=0;
    end
    else begin
        case (clkcnt)
            8'd27:futuremmap1_1[2][0]<=convtmp3;
            8'd28:futuremmap1_1[2][1]<=convtmp3;
            8'd29:futuremmap1_1[2][2]<=convtmp3;
            8'd30:futuremmap1_1[2][3]<=convtmp3;
        endcase
    end
end
always @(posedge gclk7 or negedge rst_n) begin
    if (!rst_n) begin
        futuremmap1_1[3][0]<=0;
        futuremmap1_1[3][1]<=0;
        futuremmap1_1[3][2]<=0;
        futuremmap1_1[3][3]<=0;
    end
    else begin
        case (clkcnt)
            8'd31:futuremmap1_1[3][0]<=convtmp3;
            8'd32:futuremmap1_1[3][1]<=convtmp3;
            8'd33:futuremmap1_1[3][2]<=convtmp3;
            8'd34:futuremmap1_1[3][3]<=convtmp3;
        endcase
    end
end
assign map2_1=~(clkcnt>=36&&clkcnt<=39);
GATED_OR map2_1clk(.CLOCK(clk),.SLEEP_CTRL(cg_en&&map2_1),.RST_N(rst_n),.CLOCK_GATED(mapclk1));
assign map2_2=~(clkcnt>=40&&clkcnt<=43);
GATED_OR map2_2clk(.CLOCK(clk),.SLEEP_CTRL(cg_en&&map2_2),.RST_N(rst_n),.CLOCK_GATED(mapclk2));
assign map2_3=~(clkcnt>=44&&clkcnt<=47);
GATED_OR map2_3clk(.CLOCK(clk),.SLEEP_CTRL(cg_en&&map2_3),.RST_N(rst_n),.CLOCK_GATED(mapclk3));
assign map2_4=~(clkcnt>=48&&clkcnt<=51);
GATED_OR map2_4clk(.CLOCK(clk),.SLEEP_CTRL(cg_en&&map2_4),.RST_N(rst_n),.CLOCK_GATED(mapclk4));
always @(posedge mapclk1 or negedge rst_n) begin
    if (!rst_n) begin
        futuremmap1_2[0][0]<=0;
        futuremmap1_2[0][1]<=0;
        futuremmap1_2[0][2]<=0;
        futuremmap1_2[0][3]<=0;
    end
    else begin
        case (clkcnt)
            8'd36:futuremmap1_2[0][0]<=convtmp3;
            8'd37:futuremmap1_2[0][1]<=convtmp3;
            8'd38:futuremmap1_2[0][2]<=convtmp3;
            8'd39:futuremmap1_2[0][3]<=convtmp3;
        endcase
    end
end
always @(posedge mapclk2 or negedge rst_n) begin
    if (!rst_n) begin
        futuremmap1_2[1][0]<=0;
        futuremmap1_2[1][1]<=0;
        futuremmap1_2[1][2]<=0;
        futuremmap1_2[1][3]<=0;
    end
    else begin
        case (clkcnt)
            8'd40:futuremmap1_2[1][0]<=convtmp3;
            8'd41:futuremmap1_2[1][1]<=convtmp3; 
            8'd42:futuremmap1_2[1][2]<=convtmp3;
            8'd43:futuremmap1_2[1][3]<=convtmp3;
        endcase
    end
end
always @(posedge mapclk3 or negedge rst_n) begin
    if (!rst_n) begin
        futuremmap1_2[2][0]<=0;
        futuremmap1_2[2][1]<=0;
        futuremmap1_2[2][2]<=0;
        futuremmap1_2[2][3]<=0;
    end
    else begin
        case (clkcnt)
            8'd44:futuremmap1_2[2][0]<=convtmp3;
            8'd45:futuremmap1_2[2][1]<=convtmp3;
            8'd46:futuremmap1_2[2][2]<=convtmp3;
            8'd47:futuremmap1_2[2][3]<=convtmp3;
        endcase
    end
end
always @(posedge mapclk4 or negedge rst_n) begin
    if (!rst_n) begin
        futuremmap1_2[3][0]<=0;
        futuremmap1_2[3][1]<=0;
        futuremmap1_2[3][2]<=0;
        futuremmap1_2[3][3]<=0;
    end
    else begin
        case (clkcnt)
            8'd48:futuremmap1_2[3][0]<=convtmp3;
            8'd49:futuremmap1_2[3][1]<=convtmp3;
            8'd50:futuremmap1_2[3][2]<=convtmp3;
            8'd51:futuremmap1_2[3][3]<=convtmp3;
        endcase
    end
end
assign map3_1=~(clkcnt>=53&&clkcnt<=56);
GATED_OR map3_1clk(.CLOCK(clk),.SLEEP_CTRL(cg_en&&map3_1),.RST_N(rst_n),.CLOCK_GATED(mapclk5));
assign map3_2=~(clkcnt>=57&&clkcnt<=60);
GATED_OR map3_2clk(.CLOCK(clk),.SLEEP_CTRL(cg_en&&map3_2),.RST_N(rst_n),.CLOCK_GATED(mapclk6));
assign map3_3=~(clkcnt>=61&&clkcnt<=64);
GATED_OR map3_3clk(.CLOCK(clk),.SLEEP_CTRL(cg_en&&map3_3),.RST_N(rst_n),.CLOCK_GATED(mapclk7));
assign map3_4=~(clkcnt>=65&&clkcnt<=68);
GATED_OR map3_4clk(.CLOCK(clk),.SLEEP_CTRL(cg_en&&map3_4),.RST_N(rst_n),.CLOCK_GATED(mapclk8));
always @(posedge mapclk5 or negedge rst_n) begin
    if (!rst_n) begin
        futuremmap1_3[0][0]<=0;
        futuremmap1_3[0][1]<=0;
        futuremmap1_3[0][2]<=0;
        futuremmap1_3[0][3]<=0;
    end
    else begin
        case (clkcnt)
            8'd53:futuremmap1_3[0][0]<=convtmp3;
            8'd54:futuremmap1_3[0][1]<=convtmp3;
            8'd55:futuremmap1_3[0][2]<=convtmp3;
            8'd56:futuremmap1_3[0][3]<=convtmp3;
        endcase
    end
end
always @(posedge mapclk6 or negedge rst_n) begin
    if (!rst_n) begin
        futuremmap1_3[1][0]<=0;
        futuremmap1_3[1][1]<=0;
        futuremmap1_3[1][2]<=0;
        futuremmap1_3[1][3]<=0;
    end
    else begin
        case (clkcnt)
            8'd57:futuremmap1_3[1][0]<=convtmp3;
            8'd58:futuremmap1_3[1][1]<=convtmp3; 
            8'd59:futuremmap1_3[1][2]<=convtmp3;
            8'd60:futuremmap1_3[1][3]<=convtmp3;
        endcase
    end
end
always @(posedge mapclk7 or negedge rst_n) begin
    if (!rst_n) begin
        futuremmap1_3[2][0]<=0;
        futuremmap1_3[2][1]<=0;
        futuremmap1_3[2][2]<=0;
        futuremmap1_3[2][3]<=0;
    end
    else begin
        case (clkcnt)
            8'd61:futuremmap1_3[2][0]<=convtmp3;
            8'd62:futuremmap1_3[2][1]<=convtmp3;
            8'd63:futuremmap1_3[2][2]<=convtmp3;
            8'd64:futuremmap1_3[2][3]<=convtmp3;
        endcase
    end
end
always @(posedge mapclk8 or negedge rst_n) begin
    if (!rst_n) begin
        futuremmap1_3[3][0]<=0;
        futuremmap1_3[3][1]<=0;
        futuremmap1_3[3][2]<=0;
        futuremmap1_3[3][3]<=0;
    end
    else begin
        case (clkcnt)
            8'd65:futuremmap1_3[3][0]<=convtmp3;
            8'd66:futuremmap1_3[3][1]<=convtmp3;
            8'd67:futuremmap1_3[3][2]<=convtmp3;
            8'd68:futuremmap1_3[3][3]<=convtmp3;
        endcase
    end
end
assign map4_1=~(clkcnt>=70&&clkcnt<=73);
GATED_OR map4_1clk(.CLOCK(clk),.SLEEP_CTRL(cg_en&&map4_1),.RST_N(rst_n),.CLOCK_GATED(mapclk9));
assign map4_2=~(clkcnt>=74&&clkcnt<=77);
GATED_OR map4_2clk(.CLOCK(clk),.SLEEP_CTRL(cg_en&&map4_2),.RST_N(rst_n),.CLOCK_GATED(mapclk10));
assign map4_3=~(clkcnt>=78&&clkcnt<=81);
GATED_OR map4_3clk(.CLOCK(clk),.SLEEP_CTRL(cg_en&&map4_3),.RST_N(rst_n),.CLOCK_GATED(mapclk11));
assign map4_4=~(clkcnt>=82&&clkcnt<=85);
GATED_OR map4_4clk(.CLOCK(clk),.SLEEP_CTRL(cg_en&&map4_4),.RST_N(rst_n),.CLOCK_GATED(mapclk12));
always @(posedge mapclk9 or negedge rst_n) begin
    if (!rst_n) begin
        futuremmap2_1[0][0]<=0;
        futuremmap2_1[0][1]<=0;
        futuremmap2_1[0][2]<=0;
        futuremmap2_1[0][3]<=0;
    end
    else begin
        case (clkcnt)
            8'd70:futuremmap2_1[0][0]<=convtmp3;
            8'd71:futuremmap2_1[0][1]<=convtmp3;
            8'd72:futuremmap2_1[0][2]<=convtmp3;
            8'd73:futuremmap2_1[0][3]<=convtmp3;
        endcase
    end
end
always @(posedge mapclk10 or negedge rst_n) begin
    if (!rst_n) begin
        futuremmap2_1[1][0]<=0;
        futuremmap2_1[1][1]<=0;
        futuremmap2_1[1][2]<=0;
        futuremmap2_1[1][3]<=0;
    end
    else begin
        case (clkcnt)
            8'd74:futuremmap2_1[1][0]<=convtmp3;
            8'd75:futuremmap2_1[1][1]<=convtmp3; 
            8'd76:futuremmap2_1[1][2]<=convtmp3;
            8'd77:futuremmap2_1[1][3]<=convtmp3;
        endcase
    end
end
always @(posedge mapclk11 or negedge rst_n) begin
    if (!rst_n) begin
        futuremmap2_1[2][0]<=0;
        futuremmap2_1[2][1]<=0;
        futuremmap2_1[2][2]<=0;
        futuremmap2_1[2][3]<=0;
    end
    else begin
        case (clkcnt)
            8'd78:futuremmap2_1[2][0]<=convtmp3;
            8'd79:futuremmap2_1[2][1]<=convtmp3;
            8'd80:futuremmap2_1[2][2]<=convtmp3;
            8'd81:futuremmap2_1[2][3]<=convtmp3;
        endcase
    end
end
always @(posedge mapclk12 or negedge rst_n) begin
    if (!rst_n) begin
        futuremmap2_1[3][0]<=0;
        futuremmap2_1[3][1]<=0;
        futuremmap2_1[3][2]<=0;
        futuremmap2_1[3][3]<=0;
    end
    else begin
        case (clkcnt)
            8'd82:futuremmap2_1[3][0]<=convtmp3;
            8'd83:futuremmap2_1[3][1]<=convtmp3;
            8'd84:futuremmap2_1[3][2]<=convtmp3;
            8'd85:futuremmap2_1[3][3]<=convtmp3;
        endcase
    end
end
assign map5_1=~(clkcnt>=87&&clkcnt<=90);
GATED_OR map5_1clk(.CLOCK(clk),.SLEEP_CTRL(cg_en&&map5_1),.RST_N(rst_n),.CLOCK_GATED(mapclk13));
assign map5_2=~(clkcnt>=91&&clkcnt<=94);
GATED_OR map5_2clk(.CLOCK(clk),.SLEEP_CTRL(cg_en&&map5_2),.RST_N(rst_n),.CLOCK_GATED(mapclk14));
assign map5_3=~(clkcnt>=95&&clkcnt<=98);
GATED_OR map5_3clk(.CLOCK(clk),.SLEEP_CTRL(cg_en&&map5_3),.RST_N(rst_n),.CLOCK_GATED(mapclk15));
assign map5_4=~(clkcnt>=99&&clkcnt<=102);
GATED_OR map5_4clk(.CLOCK(clk),.SLEEP_CTRL(cg_en&&map5_4),.RST_N(rst_n),.CLOCK_GATED(mapclk16));
always @(posedge mapclk13 or negedge rst_n) begin
    if (!rst_n) begin
        futuremmap2_2[0][0]<=0;
        futuremmap2_2[0][1]<=0;
        futuremmap2_2[0][2]<=0;
        futuremmap2_2[0][3]<=0;
    end
    else begin
        case (clkcnt)
            8'd87:futuremmap2_2[0][0]<=convtmp3;
            8'd88:futuremmap2_2[0][1]<=convtmp3;
            8'd89:futuremmap2_2[0][2]<=convtmp3;
            8'd90:futuremmap2_2[0][3]<=convtmp3;
        endcase
    end
end
always @(posedge mapclk14 or negedge rst_n) begin
    if (!rst_n) begin
        futuremmap2_2[1][0]<=0;
        futuremmap2_2[1][1]<=0;
        futuremmap2_2[1][2]<=0;
        futuremmap2_2[1][3]<=0;
    end
    else begin
        case (clkcnt)
            8'd91:futuremmap2_2[1][0]<=convtmp3;
            8'd92:futuremmap2_2[1][1]<=convtmp3; 
            8'd93:futuremmap2_2[1][2]<=convtmp3;
            8'd94:futuremmap2_2[1][3]<=convtmp3;
        endcase
    end
end
always @(posedge mapclk15 or negedge rst_n) begin
    if (!rst_n) begin
        futuremmap2_2[2][0]<=0;
        futuremmap2_2[2][1]<=0;
        futuremmap2_2[2][2]<=0;
        futuremmap2_2[2][3]<=0;
    end
    else begin
        case (clkcnt)
            8'd95:futuremmap2_2[2][0]<=convtmp3;
            8'd96:futuremmap2_2[2][1]<=convtmp3;
            8'd97:futuremmap2_2[2][2]<=convtmp3;
            8'd98:futuremmap2_2[2][3]<=convtmp3;
        endcase
    end
end
always @(posedge mapclk16 or negedge rst_n) begin
    if (!rst_n) begin
        futuremmap2_2[3][0]<=0;
        futuremmap2_2[3][1]<=0;
        futuremmap2_2[3][2]<=0;
        futuremmap2_2[3][3]<=0;
    end
    else begin
        case (clkcnt)
            8'd99:futuremmap2_2[3][0]<=convtmp3;
            8'd100:futuremmap2_2[3][1]<=convtmp3;
            8'd101:futuremmap2_2[3][2]<=convtmp3;
            8'd102:futuremmap2_2[3][3]<=convtmp3;
        endcase
    end
end
assign map6_1=~(clkcnt>=104&&clkcnt<=107);
GATED_OR map6_1clk(.CLOCK(clk),.SLEEP_CTRL(cg_en&&map6_1),.RST_N(rst_n),.CLOCK_GATED(mapclk17));
assign map6_2=~(clkcnt>=108&&clkcnt<=111);
GATED_OR map6_2clk(.CLOCK(clk),.SLEEP_CTRL(cg_en&&map6_2),.RST_N(rst_n),.CLOCK_GATED(mapclk18));
assign map6_3=~(clkcnt>=112&&clkcnt<=115);
GATED_OR map6_3clk(.CLOCK(clk),.SLEEP_CTRL(cg_en&&map6_3),.RST_N(rst_n),.CLOCK_GATED(mapclk19));
assign map6_4=~(clkcnt>=116&&clkcnt<=119);
GATED_OR map6_4clk(.CLOCK(clk),.SLEEP_CTRL(cg_en&&map6_4),.RST_N(rst_n),.CLOCK_GATED(mapclk20));
always @(posedge mapclk17 or negedge rst_n) begin
    if (!rst_n) begin
        futuremmap2_3[0][0]<=0;
        futuremmap2_3[0][1]<=0;
        futuremmap2_3[0][2]<=0;
        futuremmap2_3[0][3]<=0;
    end
    else begin
        case (clkcnt)
            8'd104:futuremmap2_3[0][0]<=convtmp3;
            8'd105:futuremmap2_3[0][1]<=convtmp3;
            8'd106:futuremmap2_3[0][2]<=convtmp3;
            8'd107:futuremmap2_3[0][3]<=convtmp3;
        endcase
    end
end
always @(posedge mapclk18 or negedge rst_n) begin
    if (!rst_n) begin
        futuremmap2_3[1][0]<=0;
        futuremmap2_3[1][1]<=0;
        futuremmap2_3[1][2]<=0;
        futuremmap2_3[1][3]<=0;
    end
    else begin
        case (clkcnt)
            8'd108:futuremmap2_3[1][0]<=convtmp3;
            8'd109:futuremmap2_3[1][1]<=convtmp3; 
            8'd110:futuremmap2_3[1][2]<=convtmp3;
            8'd111:futuremmap2_3[1][3]<=convtmp3;
        endcase
    end
end
always @(posedge mapclk19 or negedge rst_n) begin
    if (!rst_n) begin
        futuremmap2_3[2][0]<=0;
        futuremmap2_3[2][1]<=0;
        futuremmap2_3[2][2]<=0;
        futuremmap2_3[2][3]<=0;
    end
    else begin
        case (clkcnt)
            8'd112:futuremmap2_3[2][0]<=convtmp3;
            8'd113:futuremmap2_3[2][1]<=convtmp3;
            8'd114:futuremmap2_3[2][2]<=convtmp3;
            8'd115:futuremmap2_3[2][3]<=convtmp3;
        endcase
    end
end
always @(posedge mapclk20 or negedge rst_n) begin
    if (!rst_n) begin
        futuremmap2_3[3][0]<=0;
        futuremmap2_3[3][1]<=0;
        futuremmap2_3[3][2]<=0;
        futuremmap2_3[3][3]<=0;
    end
    else begin
        case (clkcnt)
            8'd116:futuremmap2_3[3][0]<=convtmp3;
            8'd117:futuremmap2_3[3][1]<=convtmp3;
            8'd118:futuremmap2_3[3][2]<=convtmp3;
            8'd119:futuremmap2_3[3][3]<=convtmp3;
        endcase
    end
end
assign sum3_1=~((clkcnt>=18&&clkcnt<=118)||(clkcnt>=127&&clkcnt<=141)||(clkcnt>=156&&clkcnt<=162));
GATED_OR sum3_1clk(.CLOCK(clk),.SLEEP_CTRL(cg_en&&sum3_1),.RST_N(rst_n),.CLOCK_GATED(gclk10));
assign sum3_2=~((clkcnt>=54&&clkcnt<=69)||(clkcnt>=105&&clkcnt<=120)||clkcnt==138||clkcnt==140||clkcnt==156||clkcnt==158||clkcnt==160||clkcnt==162);
GATED_OR sum3_2clk(.CLOCK(clk),.SLEEP_CTRL(cg_en&&sum3_2),.RST_N(rst_n),.CLOCK_GATED(gclk11));
always @(posedge gclk10 or negedge rst_n) begin
    if (!rst_n) begin
        addforthree1<=0;
        addforthree2<=0;
        addforthree3<=0;
    end
    else begin
        if (clkcnt>=18 && clkcnt<=118) begin
            addforthree1<=sum1;
            addforthree2<=sum2;
            addforthree3<=sum3;
        end
        else begin
        case (clkcnt) 
            8'd127:begin
                addforthree1<=normmax1;
                addforthree2<=normmin1;
                addforthree3<=0;
            end
            8'd128:begin
                addforthree1<=fully1[0];
                addforthree2<=normmin1;
                addforthree3<=0;
            end
            8'd129:begin
                addforthree1<=fully1[1];
                addforthree2<=normmin1;
                addforthree3<=0;
            end
            8'd130:begin
                addforthree1<=fully1[2];
                addforthree2<=normmin1;
                addforthree3<=0;
            end
            8'd131:begin
                addforthree1<=fully1[3];
                addforthree2<=normmin1;
                addforthree3<=0;
            end
            8'd134:begin
                addforthree1<=exp1_1pos;
                addforthree2<={!exp1_1neg[31],exp1_1neg[30:0]};
                addforthree3<=0;
            end
            8'd136:begin
                addforthree1<=exp1_2pos;
                addforthree2<={!exp1_2neg[31],exp1_2neg[30:0]};
                addforthree3<=0;
            end
            8'd138:begin
                addforthree1<=exp1_3pos;
                addforthree2<={!exp1_3neg[31],exp1_3neg[30:0]};
                addforthree3<=0;
            end
            8'd139:begin
                case (optreg[1])
                    1'b0:begin
                        addforthree1<=one;
                        addforthree2<=exp1_2neg;
                        addforthree3<=0;
                    end 
                    1'b1:begin
                        addforthree1<=exp1_2pos;
                        addforthree2<=exp1_2neg;
                        addforthree3<=0;
                    end
                endcase
            end
            8'd140:begin
                case (optreg[1])
                    1'b0:begin
                        addforthree1<=one;
                        addforthree2<=exp1_3neg;
                        addforthree3<=0;
                    end 
                    1'b1:begin
                        addforthree1<=exp1_3pos;
                        addforthree2<=exp1_3neg;
                        addforthree3<=0;
                    end
                endcase
            end
            8'd141:begin
                case (optreg[1])
                    1'b0:begin
                        addforthree1<=one;
                        addforthree2<=exp1_4neg;
                        addforthree3<=0;
                    end 
                    1'b1:begin
                        addforthree1<=exp1_4pos;
                        addforthree2<=exp1_4neg;
                        addforthree3<=0;
                    end
                endcase
            end
            8'd156:begin
                case (optreg[1])
                    1'b0:begin
                        addforthree1<=one;
                        addforthree2<=exp2_1neg;
                        addforthree3<=0;
                    end 
                    1'b1:begin
                        addforthree1<=exp2_1pos;
                        addforthree2<=exp2_1neg;
                        addforthree3<=0;
                    end
                endcase
            end
            8'd158:begin
                case (optreg[1])
                    1'b0:begin
                        addforthree1<=one;
                        addforthree2<=exp2_2neg;
                        addforthree3<=0;
                    end 
                    1'b1:begin
                        addforthree1<=exp2_2pos;
                        addforthree2<=exp2_2neg;
                        addforthree3<=0;
                    end
                endcase
            end
            8'd160:begin
                case (optreg[1])
                    1'b0:begin
                        addforthree1<=one;
                        addforthree2<=exp2_3neg;
                        addforthree3<=0;
                    end 
                    1'b1:begin
                        addforthree1<=exp2_3pos;
                        addforthree2<=exp2_3neg;
                        addforthree3<=0;
                    end
                endcase
            end
            8'd162:begin
                case (optreg[1])
                    1'b0:begin
                        addforthree1<=one;
                        addforthree2<=exp2_4neg;
                        addforthree3<=0;
                    end 
                    1'b1:begin
                        addforthree1<=exp2_4pos;
                        addforthree2<=exp2_4neg;
                        addforthree3<=0;
                    end
                endcase
            end
        endcase
        end
    end
end
always @(posedge gclk11 or negedge rst_n) begin
    if (!rst_n) begin
        addthree1<=0;
        addthree2<=0;
        addthree3<=0;
    end
    else begin
        case (clkcnt)
            8'd54:begin
                addthree1<=futuremmap1_1[0][0];
                addthree2<=futuremmap1_2[0][0];
                addthree3<=futuremmap1_3[0][0];
            end
            8'd55:begin
                addthree1<=futuremmap1_1[0][1];
                addthree2<=futuremmap1_2[0][1];
                addthree3<=futuremmap1_3[0][1];
            end 
            8'd56:begin
                addthree1<=futuremmap1_1[0][2];
                addthree2<=futuremmap1_2[0][2];
                addthree3<=futuremmap1_3[0][2];
            end 
            8'd57:begin
                addthree1<=futuremmap1_1[0][3];
                addthree2<=futuremmap1_2[0][3];
                addthree3<=futuremmap1_3[0][3];
            end 
            8'd58:begin
                addthree1<=futuremmap1_1[1][0];
                addthree2<=futuremmap1_2[1][0];
                addthree3<=futuremmap1_3[1][0];
            end 
            8'd59:begin
                addthree1<=futuremmap1_1[1][1];
                addthree2<=futuremmap1_2[1][1];
                addthree3<=futuremmap1_3[1][1];
            end 
            8'd60:begin
                addthree1<=futuremmap1_1[1][2];
                addthree2<=futuremmap1_2[1][2];
                addthree3<=futuremmap1_3[1][2];
            end 
            8'd61:begin
                addthree1<=futuremmap1_1[1][3];
                addthree2<=futuremmap1_2[1][3];
                addthree3<=futuremmap1_3[1][3];
            end 
            8'd62:begin
                addthree1<=futuremmap1_1[2][0];
                addthree2<=futuremmap1_2[2][0];
                addthree3<=futuremmap1_3[2][0];
            end 
            8'd63:begin
                addthree1<=futuremmap1_1[2][1];
                addthree2<=futuremmap1_2[2][1];
                addthree3<=futuremmap1_3[2][1];
            end 
            8'd64:begin
                addthree1<=futuremmap1_1[2][2];
                addthree2<=futuremmap1_2[2][2];
                addthree3<=futuremmap1_3[2][2];
            end 
            8'd65:begin
                addthree1<=futuremmap1_1[2][3];
                addthree2<=futuremmap1_2[2][3];
                addthree3<=futuremmap1_3[2][3];
            end 
            8'd66:begin
                addthree1<=futuremmap1_1[3][0];
                addthree2<=futuremmap1_2[3][0];
                addthree3<=futuremmap1_3[3][0];
            end 
            8'd67:begin
                addthree1<=futuremmap1_1[3][1];
                addthree2<=futuremmap1_2[3][1];
                addthree3<=futuremmap1_3[3][1];
            end 
            8'd68:begin
                addthree1<=futuremmap1_1[3][2];
                addthree2<=futuremmap1_2[3][2];
                addthree3<=futuremmap1_3[3][2];
            end 
            8'd69:begin
                addthree1<=futuremmap1_1[3][3];
                addthree2<=futuremmap1_2[3][3];
                addthree3<=futuremmap1_3[3][3];
            end
            8'd105:begin
                addthree1<=futuremmap2_1[0][0];
                addthree2<=futuremmap2_2[0][0];
                addthree3<=futuremmap2_3[0][0];
            end
            8'd106:begin
                addthree1<=futuremmap2_1[0][1];
                addthree2<=futuremmap2_2[0][1];
                addthree3<=futuremmap2_3[0][1];
            end 
            8'd107:begin
                addthree1<=futuremmap2_1[0][2];
                addthree2<=futuremmap2_2[0][2];
                addthree3<=futuremmap2_3[0][2];
            end 
            8'd108:begin
                addthree1<=futuremmap2_1[0][3];
                addthree2<=futuremmap2_2[0][3];
                addthree3<=futuremmap2_3[0][3];
            end 
            8'd109:begin
                addthree1<=futuremmap2_1[1][0];
                addthree2<=futuremmap2_2[1][0];
                addthree3<=futuremmap2_3[1][0];
            end 
            8'd110:begin
                addthree1<=futuremmap2_1[1][1];
                addthree2<=futuremmap2_2[1][1];
                addthree3<=futuremmap2_3[1][1];
            end 
            8'd111:begin
                addthree1<=futuremmap2_1[1][2];
                addthree2<=futuremmap2_2[1][2];
                addthree3<=futuremmap2_3[1][2];
            end 
            8'd112:begin
                addthree1<=futuremmap2_1[1][3];
                addthree2<=futuremmap2_2[1][3];
                addthree3<=futuremmap2_3[1][3];
            end 
            8'd113:begin
                addthree1<=futuremmap2_1[2][0];
                addthree2<=futuremmap2_2[2][0];
                addthree3<=futuremmap2_3[2][0];
            end 
            8'd114:begin
                addthree1<=futuremmap2_1[2][1];
                addthree2<=futuremmap2_2[2][1];
                addthree3<=futuremmap2_3[2][1];
            end 
            8'd115:begin
                addthree1<=futuremmap2_1[2][2];
                addthree2<=futuremmap2_2[2][2];
                addthree3<=futuremmap2_3[2][2];
            end 
            8'd116:begin
                addthree1<=futuremmap2_1[2][3];
                addthree2<=futuremmap2_2[2][3];
                addthree3<=futuremmap2_3[2][3];
            end 
            8'd117:begin
                addthree1<=futuremmap2_1[3][0];
                addthree2<=futuremmap2_2[3][0];
                addthree3<=futuremmap2_3[3][0];
            end 
            8'd118:begin
                addthree1<=futuremmap2_1[3][1];
                addthree2<=futuremmap2_2[3][1];
                addthree3<=futuremmap2_3[3][1];
            end 
            8'd119:begin
                addthree1<=futuremmap2_1[3][2];
                addthree2<=futuremmap2_2[3][2];
                addthree3<=futuremmap2_3[3][2];
            end 
            8'd120:begin
                addthree1<=futuremmap2_1[3][3];
                addthree2<=futuremmap2_2[3][3];
                addthree3<=futuremmap2_3[3][3];
            end
            8'd138:begin
                case (optreg[1])
                    1'b0:begin
                        addthree1<=one;
                        addthree2<=exp1_1neg;
                        addthree3<=0;
                    end 
                    1'b1:begin
                        addthree1<=exp1_1pos;
                        addthree2<=exp1_1neg;
                        addthree3<=0;
                    end
                endcase
            end
            8'd140:begin
                addthree1<=exp1_4pos;
                addthree2<={!exp1_4neg[31],exp1_4neg[30:0]};
                addthree3<=0;
            end
            8'd156:begin
                addthree1<=exp2_1pos;
                addthree2<={!exp2_1neg[31],exp2_1neg[30:0]};
                addthree3<=0;
            end
            8'd158:begin
                addthree1<=exp2_2pos;
                addthree2<={!exp2_2neg[31],exp2_2neg[30:0]};
                addthree3<=0;
            end
            8'd160:begin
                addthree1<=exp2_3pos;
                addthree2<={!exp2_3neg[31],exp2_3neg[30:0]};
                addthree3<=0;
            end
            8'd162:begin
                addthree1<=exp2_4pos;
                addthree2<={!exp2_4neg[31],exp2_4neg[30:0]};
                addthree3<=0;
            end
        endcase
    end
end
DW_fp_sum3 #(inst_sig_width,inst_exp_width,inst_ieee_compliance,inst_arch_type) b1(.a(addforthree1),.b(addforthree2),.c(addforthree3),.rnd(3'b0),.z(convtmp3));
DW_fp_sum3 #(inst_sig_width,inst_exp_width,inst_ieee_compliance,inst_arch_type) b2(.a(addthree1),.b(addthree2),.c(addthree3),.rnd(3'b0),.z(convtmp));
assign map7_1=~((clkcnt>=55&&clkcnt<=58)||(clkcnt>=74&&clkcnt<=77));
GATED_OR map7_1clk(.CLOCK(clk),.SLEEP_CTRL(cg_en&&map7_1),.RST_N(rst_n),.CLOCK_GATED(mapclk21));
assign map7_2=~((clkcnt>=59&&clkcnt<=62)||(clkcnt>=78&&clkcnt<=81));
GATED_OR map7_2clk(.CLOCK(clk),.SLEEP_CTRL(cg_en&&map7_2),.RST_N(rst_n),.CLOCK_GATED(mapclk22));
assign map7_3=~((clkcnt>=63&&clkcnt<=66)||(clkcnt>=82&&clkcnt<=85));
GATED_OR map7_3clk(.CLOCK(clk),.SLEEP_CTRL(cg_en&&map7_3),.RST_N(rst_n),.CLOCK_GATED(mapclk23));
assign map7_4=~((clkcnt>=67&&clkcnt<=70)||(clkcnt>=86&&clkcnt<=89));
GATED_OR map7_4clk(.CLOCK(clk),.SLEEP_CTRL(cg_en&&map7_4),.RST_N(rst_n),.CLOCK_GATED(mapclk24));
always @(posedge mapclk21 or negedge rst_n) begin
    if (!rst_n) begin
        futuremmap1[0][0]<=0;
        futuremmap1[0][1]<=0;
        futuremmap1[0][2]<=0;
        futuremmap1[0][3]<=0;
    end
    else begin
        case (clkcnt)
            8'd55:futuremmap1[0][0]<=convtmp;
            8'd56:futuremmap1[0][1]<=convtmp;
            8'd57:futuremmap1[0][2]<=convtmp;
            8'd58:futuremmap1[0][3]<=convtmp;
            8'd74:futuremmap1[0][0]<=divans;
            8'd75:futuremmap1[0][1]<=divans;
            8'd76:futuremmap1[0][2]<=divans;
            8'd77:futuremmap1[0][3]<=divans;
        endcase
    end
end
always @(posedge mapclk22 or negedge rst_n) begin
    if (!rst_n) begin
        futuremmap1[1][0]<=0;
        futuremmap1[1][1]<=0;
        futuremmap1[1][2]<=0;
        futuremmap1[1][3]<=0;
    end
    else begin
        case (clkcnt)
            8'd59:futuremmap1[1][0]<=convtmp;
            8'd60:futuremmap1[1][1]<=convtmp;
            8'd61:futuremmap1[1][2]<=convtmp;//
            8'd62:futuremmap1[1][3]<=convtmp;
            8'd78:futuremmap1[1][0]<=divans;
            8'd79:futuremmap1[1][1]<=divans;
            8'd80:futuremmap1[1][2]<=divans;//
            8'd81:futuremmap1[1][3]<=divans;
        endcase
    end
end
always @(posedge mapclk23 or negedge rst_n) begin
    if (!rst_n) begin
        futuremmap1[2][0]<=0;
        futuremmap1[2][1]<=0;
        futuremmap1[2][2]<=0;
        futuremmap1[2][3]<=0;
    end
    else begin
        case (clkcnt)
            8'd63:futuremmap1[2][0]<=convtmp;
            8'd64:futuremmap1[2][1]<=convtmp;
            8'd65:futuremmap1[2][2]<=convtmp;
            8'd66:futuremmap1[2][3]<=convtmp;
            8'd82:futuremmap1[2][0]<=divans;
            8'd83:futuremmap1[2][1]<=divans;
            8'd84:futuremmap1[2][2]<=divans;
            8'd85:futuremmap1[2][3]<=divans;
        endcase
    end
end
always @(posedge mapclk24 or negedge rst_n) begin
    if (!rst_n) begin
        futuremmap1[3][0]<=0;
        futuremmap1[3][1]<=0;
        futuremmap1[3][2]<=0;
        futuremmap1[3][3]<=0;
    end
    else begin
        case (clkcnt)
            8'd67:futuremmap1[3][0]<=convtmp;
            8'd68:futuremmap1[3][1]<=convtmp;
            8'd69:futuremmap1[3][2]<=convtmp;
            8'd70:futuremmap1[3][3]<=convtmp;
            8'd86:futuremmap1[3][0]<=divans;
            8'd87:futuremmap1[3][1]<=divans;
            8'd88:futuremmap1[3][2]<=divans;
            8'd89:futuremmap1[3][3]<=divans;
        endcase
    end
end
assign map8_1=~((clkcnt>=106&&clkcnt<=109)||(clkcnt>=125&&clkcnt<=128));
GATED_OR map8_1clk(.CLOCK(clk),.SLEEP_CTRL(cg_en&&map8_1),.RST_N(rst_n),.CLOCK_GATED(mapclk25));
assign map8_2=~((clkcnt>=110&&clkcnt<=113)||(clkcnt>=129&&clkcnt<=132));
GATED_OR map8_2clk(.CLOCK(clk),.SLEEP_CTRL(cg_en&&map8_2),.RST_N(rst_n),.CLOCK_GATED(mapclk26));
assign map8_3=~((clkcnt>=114&&clkcnt<=117)||(clkcnt>=133&&clkcnt<=136));
GATED_OR map8_3clk(.CLOCK(clk),.SLEEP_CTRL(cg_en&&map8_3),.RST_N(rst_n),.CLOCK_GATED(mapclk27));
assign map8_4=~((clkcnt>=118&&clkcnt<=121)||(clkcnt>=137&&clkcnt<=140));
GATED_OR map8_4clk(.CLOCK(clk),.SLEEP_CTRL(cg_en&&map8_4),.RST_N(rst_n),.CLOCK_GATED(mapclk28));
always @(posedge mapclk25 or negedge rst_n) begin
    if (!rst_n) begin
        futuremmap2[0][0]<=0;
        futuremmap2[0][1]<=0;
        futuremmap2[0][2]<=0;
        futuremmap2[0][3]<=0;
    end
    else begin
        case (clkcnt)
            8'd106:futuremmap2[0][0]<=convtmp;
            8'd107:futuremmap2[0][1]<=convtmp;
            8'd108:futuremmap2[0][2]<=convtmp;
            8'd109:futuremmap2[0][3]<=convtmp;
            8'd125:futuremmap2[0][0]<=divans;
            8'd126:futuremmap2[0][1]<=divans;
            8'd127:futuremmap2[0][2]<=divans;
            8'd128:futuremmap2[0][3]<=divans;
        endcase
    end
end
always @(posedge mapclk26 or negedge rst_n) begin
    if (!rst_n) begin
        futuremmap2[1][0]<=0;
        futuremmap2[1][1]<=0;
        futuremmap2[1][2]<=0;
        futuremmap2[1][3]<=0;
    end
    else begin
        case (clkcnt)
            8'd110:futuremmap2[1][0]<=convtmp;
            8'd111:futuremmap2[1][1]<=convtmp;
            8'd112:futuremmap2[1][2]<=convtmp;
            8'd113:futuremmap2[1][3]<=convtmp;
            8'd129:futuremmap2[1][0]<=divans;
            8'd130:futuremmap2[1][1]<=divans;
            8'd131:futuremmap2[1][2]<=divans;//
            8'd132:futuremmap2[1][3]<=divans;
        endcase
    end
end
always @(posedge mapclk27 or negedge rst_n) begin
    if (!rst_n) begin
        futuremmap2[2][0]<=0;
        futuremmap2[2][1]<=0;
        futuremmap2[2][2]<=0;
        futuremmap2[2][3]<=0;
    end
    else begin
        case (clkcnt)
            8'd114:futuremmap2[2][0]<=convtmp;
            8'd115:futuremmap2[2][1]<=convtmp;
            8'd116:futuremmap2[2][2]<=convtmp;
            8'd117:futuremmap2[2][3]<=convtmp;
            8'd133:futuremmap2[2][0]<=divans;
            8'd134:futuremmap2[2][1]<=divans;
            8'd135:futuremmap2[2][2]<=divans;
            8'd136:futuremmap2[2][3]<=divans;
        endcase
    end
end
always @(posedge mapclk28 or negedge rst_n) begin
    if (!rst_n) begin
        futuremmap2[3][0]<=0;
        futuremmap2[3][1]<=0;
        futuremmap2[3][2]<=0;
        futuremmap2[3][3]<=0;
    end
    else begin
        case (clkcnt)
            8'd118:futuremmap2[3][0]<=convtmp;
            8'd119:futuremmap2[3][1]<=convtmp;
            8'd120:futuremmap2[3][2]<=convtmp;
            8'd121:futuremmap2[3][3]<=convtmp;
            8'd137:futuremmap2[3][0]<=divans;
            8'd138:futuremmap2[3][1]<=divans;
            8'd139:futuremmap2[3][2]<=divans;
            8'd140:futuremmap2[3][3]<=divans;
        endcase
    end
end
//Equalization
assign pd21=~(clkcnt==71||clkcnt==122);
GATED_OR div9csdflk(.CLOCK(clk),.SLEEP_CTRL(cg_en&&pd21),.RST_N(rst_n),.CLOCK_GATED(g5));
assign pd22=~(clkcnt==71||clkcnt==122);
GATED_OR didsfsv9csdflk(.CLOCK(clk),.SLEEP_CTRL(cg_en&&pd22),.RST_N(rst_n),.CLOCK_GATED(g6));
assign pd23=~(clkcnt==71||clkcnt==122);
GATED_OR divffss9csdflk(.CLOCK(clk),.SLEEP_CTRL(cg_en&&pd23),.RST_N(rst_n),.CLOCK_GATED(g7));
assign pd24=~(clkcnt==71||clkcnt==122);
GATED_OR diaagv9csdflk(.CLOCK(clk),.SLEEP_CTRL(cg_en&&pd24),.RST_N(rst_n),.CLOCK_GATED(g8));
always @(posedge g5 or negedge rst_n) begin
    if (!rst_n) begin
        paddinginput2[0][0]<=0;
        paddinginput2[0][1]<=0;
        paddinginput2[0][2]<=0;
        paddinginput2[0][3]<=0;
    end
    else begin
        if (clkcnt==71) begin
            paddinginput2[0][0]<=futuremmap1[0][0];
            paddinginput2[0][1]<=futuremmap1[0][1];
            paddinginput2[0][2]<=futuremmap1[0][2];
            paddinginput2[0][3]<=futuremmap1[0][3];
        end
        else if (clkcnt==122) begin
            paddinginput2[0][0]<=futuremmap2[0][0];
            paddinginput2[0][1]<=futuremmap2[0][1];
            paddinginput2[0][2]<=futuremmap2[0][2];
            paddinginput2[0][3]<=futuremmap2[0][3];
        end
    end
end
always @(posedge g6 or negedge rst_n) begin
    if (!rst_n) begin
        paddinginput2[1][0]<=0;
        paddinginput2[1][1]<=0;
        paddinginput2[1][2]<=0;
        paddinginput2[1][3]<=0;
    end
    else begin
        if (clkcnt==71) begin
            paddinginput2[1][0]<=futuremmap1[1][0];
            paddinginput2[1][1]<=futuremmap1[1][1];
            paddinginput2[1][2]<=futuremmap1[1][2];
            paddinginput2[1][3]<=futuremmap1[1][3];
        end
        else if (clkcnt==122) begin
            paddinginput2[1][0]<=futuremmap2[1][0];
            paddinginput2[1][1]<=futuremmap2[1][1];
            paddinginput2[1][2]<=futuremmap2[1][2];
            paddinginput2[1][3]<=futuremmap2[1][3];
        end
    end
end
always @(posedge g7 or negedge rst_n) begin
    if (!rst_n) begin
        paddinginput2[2][0]<=0;
        paddinginput2[2][1]<=0;
        paddinginput2[2][2]<=0;
        paddinginput2[2][3]<=0;
    end
    else begin
        if (clkcnt==71) begin
            paddinginput2[2][0]<=futuremmap1[2][0];
            paddinginput2[2][1]<=futuremmap1[2][1];
            paddinginput2[2][2]<=futuremmap1[2][2];
            paddinginput2[2][3]<=futuremmap1[2][3];
        end
        else if (clkcnt==122) begin
            paddinginput2[2][0]<=futuremmap2[2][0];
            paddinginput2[2][1]<=futuremmap2[2][1];
            paddinginput2[2][2]<=futuremmap2[2][2];
            paddinginput2[2][3]<=futuremmap2[2][3];
        end
    end
end
always @(posedge g8 or negedge rst_n) begin
    if (!rst_n) begin
        paddinginput2[3][0]<=0;
        paddinginput2[3][1]<=0;
        paddinginput2[3][2]<=0;
        paddinginput2[3][3]<=0;
    end
    else begin
        if (clkcnt==71) begin
            paddinginput2[3][0]<=futuremmap1[3][0];
            paddinginput2[3][1]<=futuremmap1[3][1];
            paddinginput2[3][2]<=futuremmap1[3][2];
            paddinginput2[3][3]<=futuremmap1[3][3];
        end
        else if (clkcnt==122) begin
            paddinginput2[3][0]<=futuremmap2[3][0];
            paddinginput2[3][1]<=futuremmap2[3][1];
            paddinginput2[3][2]<=futuremmap2[3][2];
            paddinginput2[3][3]<=futuremmap2[3][3];
        end
    end
end
always @(*) begin
    if(optreg[0] == 1'b1) begin
        equalizationpadding[0][0] = 32'b0;
        equalizationpadding[0][1] = 32'b0;
        equalizationpadding[0][2] = 32'b0;
        equalizationpadding[0][3] = 32'b0;
        equalizationpadding[0][4] = 32'b0;
        equalizationpadding[0][5] = 32'b0;
        equalizationpadding[1][0] = 32'b0;
        equalizationpadding[1][5] = 32'b0;
        equalizationpadding[2][0] = 32'b0;
        equalizationpadding[2][5] = 32'b0;
        equalizationpadding[3][0] = 32'b0;
        equalizationpadding[3][5] = 32'b0;
        equalizationpadding[4][0] = 32'b0;
        equalizationpadding[4][5] = 32'b0;
        equalizationpadding[5][0] = 32'b0;
        equalizationpadding[5][1] = 32'b0;
        equalizationpadding[5][2] = 32'b0;
        equalizationpadding[5][3] = 32'b0;
        equalizationpadding[5][4] = 32'b0;
        equalizationpadding[5][5] = 32'b0;
    end
    else begin
        equalizationpadding[0][0] = paddinginput2[0][0];
        equalizationpadding[0][1] = paddinginput2[0][0];
        equalizationpadding[0][2] = paddinginput2[0][1];
        equalizationpadding[0][3] = paddinginput2[0][2];
        equalizationpadding[0][4] = paddinginput2[0][3];
        equalizationpadding[0][5] = paddinginput2[0][3];
        equalizationpadding[1][0] = paddinginput2[0][0];
        equalizationpadding[1][5] = paddinginput2[0][3];
        equalizationpadding[2][0] = paddinginput2[1][0];
        equalizationpadding[2][5] = paddinginput2[1][3];
        equalizationpadding[3][0] = paddinginput2[2][0];
        equalizationpadding[3][5] = paddinginput2[2][3];
        equalizationpadding[4][0] = paddinginput2[3][0];
        equalizationpadding[4][5] = paddinginput2[3][3];
        equalizationpadding[5][0] = paddinginput2[3][0];
        equalizationpadding[5][1] = paddinginput2[3][0];
        equalizationpadding[5][2] = paddinginput2[3][1];
        equalizationpadding[5][3] = paddinginput2[3][2];
        equalizationpadding[5][4] = paddinginput2[3][3];
        equalizationpadding[5][5] = paddinginput2[3][3];
    end
    for(integer ii = 0; ii < 4; ii = ii+1) begin
        for(integer jj = 0; jj < 4; jj = jj + 1) begin
            equalizationpadding[ii+1][jj+1] = paddinginput2[ii][jj];
        end
    end
end
DW_fp_sum3 #(inst_sig_width,inst_exp_width,inst_ieee_compliance,inst_arch_type) b3(.a(equalizationadd1),.b(equalizationadd2),.c(equalizationadd3),.rnd(3'b0),.z(equalizationsum1));
DW_fp_sum3 #(inst_sig_width,inst_exp_width,inst_ieee_compliance,inst_arch_type) b4(.a(equalizationadd4),.b(equalizationadd5),.c(equalizationadd6),.rnd(3'b0),.z(equalizationsum2));
DW_fp_sum3 #(inst_sig_width,inst_exp_width,inst_ieee_compliance,inst_arch_type) b5(.a(equalizationadd7),.b(equalizationadd8),.c(equalizationadd9),.rnd(3'b0),.z(equalizationsum3));
DW_fp_sum3 #(inst_sig_width,inst_exp_width,inst_ieee_compliance,inst_arch_type) b6(.a(equalizationsum1),.b(equalizationsum2),.c(equalizationsum3),.rnd(3'b0),.z(equalizationsum4));
always @(*) begin
    case (clkcnt)
        72:begin
            equalizationadd1=equalizationpadding[0][0];
            equalizationadd2=equalizationpadding[0][1];
            equalizationadd3=equalizationpadding[0][2];
            equalizationadd4=equalizationpadding[1][0];
            equalizationadd5=equalizationpadding[1][1];
            equalizationadd6=equalizationpadding[1][2];
            equalizationadd7=equalizationpadding[2][0];
            equalizationadd8=equalizationpadding[2][1];
            equalizationadd9=equalizationpadding[2][2];
        end
        73:begin
            equalizationadd1=equalizationpadding[0][1];
            equalizationadd2=equalizationpadding[0][2];
            equalizationadd3=equalizationpadding[0][3];
            equalizationadd4=equalizationpadding[1][1];
            equalizationadd5=equalizationpadding[1][2];
            equalizationadd6=equalizationpadding[1][3];
            equalizationadd7=equalizationpadding[2][1];
            equalizationadd8=equalizationpadding[2][2];
            equalizationadd9=equalizationpadding[2][3];
        end
        74:begin
            equalizationadd1=equalizationpadding[0][2];
            equalizationadd2=equalizationpadding[0][3];
            equalizationadd3=equalizationpadding[0][4];
            equalizationadd4=equalizationpadding[1][2];
            equalizationadd5=equalizationpadding[1][3];
            equalizationadd6=equalizationpadding[1][4];
            equalizationadd7=equalizationpadding[2][2];
            equalizationadd8=equalizationpadding[2][3];
            equalizationadd9=equalizationpadding[2][4];
        end
        75:begin
            equalizationadd1=equalizationpadding[0][3];
            equalizationadd2=equalizationpadding[0][4];
            equalizationadd3=equalizationpadding[0][5];
            equalizationadd4=equalizationpadding[1][3];
            equalizationadd5=equalizationpadding[1][4];
            equalizationadd6=equalizationpadding[1][5];
            equalizationadd7=equalizationpadding[2][3];
            equalizationadd8=equalizationpadding[2][4];
            equalizationadd9=equalizationpadding[2][5];
        end
        76:begin
            equalizationadd1=equalizationpadding[1][0];
            equalizationadd2=equalizationpadding[1][1];
            equalizationadd3=equalizationpadding[1][2];
            equalizationadd4=equalizationpadding[2][0];
            equalizationadd5=equalizationpadding[2][1];
            equalizationadd6=equalizationpadding[2][2];
            equalizationadd7=equalizationpadding[3][0];
            equalizationadd8=equalizationpadding[3][1];
            equalizationadd9=equalizationpadding[3][2];
        end
        77:begin
            equalizationadd1=equalizationpadding[1][1];
            equalizationadd2=equalizationpadding[1][2];
            equalizationadd3=equalizationpadding[1][3];
            equalizationadd4=equalizationpadding[2][1];
            equalizationadd5=equalizationpadding[2][2];
            equalizationadd6=equalizationpadding[2][3];
            equalizationadd7=equalizationpadding[3][1];
            equalizationadd8=equalizationpadding[3][2];
            equalizationadd9=equalizationpadding[3][3];
        end
        78:begin
            equalizationadd1=equalizationpadding[1][2];
            equalizationadd2=equalizationpadding[1][3];
            equalizationadd3=equalizationpadding[1][4];
            equalizationadd4=equalizationpadding[2][2];
            equalizationadd5=equalizationpadding[2][3];
            equalizationadd6=equalizationpadding[2][4];
            equalizationadd7=equalizationpadding[3][2];
            equalizationadd8=equalizationpadding[3][3];
            equalizationadd9=equalizationpadding[3][4];
        end
        79:begin
            equalizationadd1=equalizationpadding[1][3];
            equalizationadd2=equalizationpadding[1][4];
            equalizationadd3=equalizationpadding[1][5];
            equalizationadd4=equalizationpadding[2][3];
            equalizationadd5=equalizationpadding[2][4];
            equalizationadd6=equalizationpadding[2][5];
            equalizationadd7=equalizationpadding[3][3];
            equalizationadd8=equalizationpadding[3][4];
            equalizationadd9=equalizationpadding[3][5];
        end
        80:begin
            equalizationadd1=equalizationpadding[2][0];
            equalizationadd2=equalizationpadding[2][1];
            equalizationadd3=equalizationpadding[2][2];
            equalizationadd4=equalizationpadding[3][0];
            equalizationadd5=equalizationpadding[3][1];
            equalizationadd6=equalizationpadding[3][2];
            equalizationadd7=equalizationpadding[4][0];
            equalizationadd8=equalizationpadding[4][1];
            equalizationadd9=equalizationpadding[4][2];
        end
        81:begin
            equalizationadd1=equalizationpadding[2][1];
            equalizationadd2=equalizationpadding[2][2];
            equalizationadd3=equalizationpadding[2][3];
            equalizationadd4=equalizationpadding[3][1];
            equalizationadd5=equalizationpadding[3][2];
            equalizationadd6=equalizationpadding[3][3];
            equalizationadd7=equalizationpadding[4][1];
            equalizationadd8=equalizationpadding[4][2];
            equalizationadd9=equalizationpadding[4][3];
        end
        82:begin
            equalizationadd1=equalizationpadding[2][2];
            equalizationadd2=equalizationpadding[2][3];
            equalizationadd3=equalizationpadding[2][4];
            equalizationadd4=equalizationpadding[3][2];
            equalizationadd5=equalizationpadding[3][3];
            equalizationadd6=equalizationpadding[3][4];
            equalizationadd7=equalizationpadding[4][2];
            equalizationadd8=equalizationpadding[4][3];
            equalizationadd9=equalizationpadding[4][4];
        end
        83:begin
            equalizationadd1=equalizationpadding[2][3];
            equalizationadd2=equalizationpadding[2][4];
            equalizationadd3=equalizationpadding[2][5];
            equalizationadd4=equalizationpadding[3][3];
            equalizationadd5=equalizationpadding[3][4];
            equalizationadd6=equalizationpadding[3][5];
            equalizationadd7=equalizationpadding[4][3];
            equalizationadd8=equalizationpadding[4][4];
            equalizationadd9=equalizationpadding[4][5];
        end
        84:begin
            equalizationadd1=equalizationpadding[3][0];
            equalizationadd2=equalizationpadding[3][1];
            equalizationadd3=equalizationpadding[3][2];
            equalizationadd4=equalizationpadding[4][0];
            equalizationadd5=equalizationpadding[4][1];
            equalizationadd6=equalizationpadding[4][2];
            equalizationadd7=equalizationpadding[5][0];
            equalizationadd8=equalizationpadding[5][1];
            equalizationadd9=equalizationpadding[5][2];
        end
        85:begin
            equalizationadd1=equalizationpadding[3][1];
            equalizationadd2=equalizationpadding[3][2];
            equalizationadd3=equalizationpadding[3][3];
            equalizationadd4=equalizationpadding[4][1];
            equalizationadd5=equalizationpadding[4][2];
            equalizationadd6=equalizationpadding[4][3];
            equalizationadd7=equalizationpadding[5][1];
            equalizationadd8=equalizationpadding[5][2];
            equalizationadd9=equalizationpadding[5][3];
        end
        86:begin
            equalizationadd1=equalizationpadding[3][2];
            equalizationadd2=equalizationpadding[3][3];
            equalizationadd3=equalizationpadding[3][4];
            equalizationadd4=equalizationpadding[4][2];
            equalizationadd5=equalizationpadding[4][3];
            equalizationadd6=equalizationpadding[4][4];
            equalizationadd7=equalizationpadding[5][2];
            equalizationadd8=equalizationpadding[5][3];
            equalizationadd9=equalizationpadding[5][4];
        end
        87:begin
            equalizationadd1=equalizationpadding[3][3];
            equalizationadd2=equalizationpadding[3][4];
            equalizationadd3=equalizationpadding[3][5];
            equalizationadd4=equalizationpadding[4][3];
            equalizationadd5=equalizationpadding[4][4];
            equalizationadd6=equalizationpadding[4][5];
            equalizationadd7=equalizationpadding[5][3];
            equalizationadd8=equalizationpadding[5][4];
            equalizationadd9=equalizationpadding[5][5];
        end
        123:begin
            equalizationadd1=equalizationpadding[0][0];
            equalizationadd2=equalizationpadding[0][1];
            equalizationadd3=equalizationpadding[0][2];
            equalizationadd4=equalizationpadding[1][0];
            equalizationadd5=equalizationpadding[1][1];
            equalizationadd6=equalizationpadding[1][2];
            equalizationadd7=equalizationpadding[2][0];
            equalizationadd8=equalizationpadding[2][1];
            equalizationadd9=equalizationpadding[2][2];
        end
        124:begin
            equalizationadd1=equalizationpadding[0][1];
            equalizationadd2=equalizationpadding[0][2];
            equalizationadd3=equalizationpadding[0][3];
            equalizationadd4=equalizationpadding[1][1];
            equalizationadd5=equalizationpadding[1][2];
            equalizationadd6=equalizationpadding[1][3];
            equalizationadd7=equalizationpadding[2][1];
            equalizationadd8=equalizationpadding[2][2];
            equalizationadd9=equalizationpadding[2][3];
        end
        125:begin
            equalizationadd1=equalizationpadding[0][2];
            equalizationadd2=equalizationpadding[0][3];
            equalizationadd3=equalizationpadding[0][4];
            equalizationadd4=equalizationpadding[1][2];
            equalizationadd5=equalizationpadding[1][3];
            equalizationadd6=equalizationpadding[1][4];
            equalizationadd7=equalizationpadding[2][2];
            equalizationadd8=equalizationpadding[2][3];
            equalizationadd9=equalizationpadding[2][4];
        end
        126:begin
            equalizationadd1=equalizationpadding[0][3];
            equalizationadd2=equalizationpadding[0][4];
            equalizationadd3=equalizationpadding[0][5];
            equalizationadd4=equalizationpadding[1][3];
            equalizationadd5=equalizationpadding[1][4];
            equalizationadd6=equalizationpadding[1][5];
            equalizationadd7=equalizationpadding[2][3];
            equalizationadd8=equalizationpadding[2][4];
            equalizationadd9=equalizationpadding[2][5];
        end
        127:begin
            equalizationadd1=equalizationpadding[1][0];
            equalizationadd2=equalizationpadding[1][1];
            equalizationadd3=equalizationpadding[1][2];
            equalizationadd4=equalizationpadding[2][0];
            equalizationadd5=equalizationpadding[2][1];
            equalizationadd6=equalizationpadding[2][2];
            equalizationadd7=equalizationpadding[3][0];
            equalizationadd8=equalizationpadding[3][1];
            equalizationadd9=equalizationpadding[3][2];
        end
        128:begin
            equalizationadd1=equalizationpadding[1][1];
            equalizationadd2=equalizationpadding[1][2];
            equalizationadd3=equalizationpadding[1][3];
            equalizationadd4=equalizationpadding[2][1];
            equalizationadd5=equalizationpadding[2][2];
            equalizationadd6=equalizationpadding[2][3];
            equalizationadd7=equalizationpadding[3][1];
            equalizationadd8=equalizationpadding[3][2];
            equalizationadd9=equalizationpadding[3][3];
        end
        129:begin
            equalizationadd1=equalizationpadding[1][2];
            equalizationadd2=equalizationpadding[1][3];
            equalizationadd3=equalizationpadding[1][4];
            equalizationadd4=equalizationpadding[2][2];
            equalizationadd5=equalizationpadding[2][3];
            equalizationadd6=equalizationpadding[2][4];
            equalizationadd7=equalizationpadding[3][2];
            equalizationadd8=equalizationpadding[3][3];
            equalizationadd9=equalizationpadding[3][4];
        end
        130:begin
            equalizationadd1=equalizationpadding[1][3];
            equalizationadd2=equalizationpadding[1][4];
            equalizationadd3=equalizationpadding[1][5];
            equalizationadd4=equalizationpadding[2][3];
            equalizationadd5=equalizationpadding[2][4];
            equalizationadd6=equalizationpadding[2][5];
            equalizationadd7=equalizationpadding[3][3];
            equalizationadd8=equalizationpadding[3][4];
            equalizationadd9=equalizationpadding[3][5];
        end
        131:begin
            equalizationadd1=equalizationpadding[2][0];
            equalizationadd2=equalizationpadding[2][1];
            equalizationadd3=equalizationpadding[2][2];
            equalizationadd4=equalizationpadding[3][0];
            equalizationadd5=equalizationpadding[3][1];
            equalizationadd6=equalizationpadding[3][2];
            equalizationadd7=equalizationpadding[4][0];
            equalizationadd8=equalizationpadding[4][1];
            equalizationadd9=equalizationpadding[4][2];
        end
        132:begin
            equalizationadd1=equalizationpadding[2][1];
            equalizationadd2=equalizationpadding[2][2];
            equalizationadd3=equalizationpadding[2][3];
            equalizationadd4=equalizationpadding[3][1];
            equalizationadd5=equalizationpadding[3][2];
            equalizationadd6=equalizationpadding[3][3];
            equalizationadd7=equalizationpadding[4][1];
            equalizationadd8=equalizationpadding[4][2];
            equalizationadd9=equalizationpadding[4][3];
        end
        133:begin
            equalizationadd1=equalizationpadding[2][2];
            equalizationadd2=equalizationpadding[2][3];
            equalizationadd3=equalizationpadding[2][4];
            equalizationadd4=equalizationpadding[3][2];
            equalizationadd5=equalizationpadding[3][3];
            equalizationadd6=equalizationpadding[3][4];
            equalizationadd7=equalizationpadding[4][2];
            equalizationadd8=equalizationpadding[4][3];
            equalizationadd9=equalizationpadding[4][4];
        end
        134:begin
            equalizationadd1=equalizationpadding[2][3];
            equalizationadd2=equalizationpadding[2][4];
            equalizationadd3=equalizationpadding[2][5];
            equalizationadd4=equalizationpadding[3][3];
            equalizationadd5=equalizationpadding[3][4];
            equalizationadd6=equalizationpadding[3][5];
            equalizationadd7=equalizationpadding[4][3];
            equalizationadd8=equalizationpadding[4][4];
            equalizationadd9=equalizationpadding[4][5];
        end
        135:begin
            equalizationadd1=equalizationpadding[3][0];
            equalizationadd2=equalizationpadding[3][1];
            equalizationadd3=equalizationpadding[3][2];
            equalizationadd4=equalizationpadding[4][0];
            equalizationadd5=equalizationpadding[4][1];
            equalizationadd6=equalizationpadding[4][2];
            equalizationadd7=equalizationpadding[5][0];
            equalizationadd8=equalizationpadding[5][1];
            equalizationadd9=equalizationpadding[5][2];
        end
        136:begin
            equalizationadd1=equalizationpadding[3][1];
            equalizationadd2=equalizationpadding[3][2];
            equalizationadd3=equalizationpadding[3][3];
            equalizationadd4=equalizationpadding[4][1];
            equalizationadd5=equalizationpadding[4][2];
            equalizationadd6=equalizationpadding[4][3];
            equalizationadd7=equalizationpadding[5][1];
            equalizationadd8=equalizationpadding[5][2];
            equalizationadd9=equalizationpadding[5][3];
        end
        137:begin
            equalizationadd1=equalizationpadding[3][2];
            equalizationadd2=equalizationpadding[3][3];
            equalizationadd3=equalizationpadding[3][4];
            equalizationadd4=equalizationpadding[4][2];
            equalizationadd5=equalizationpadding[4][3];
            equalizationadd6=equalizationpadding[4][4];
            equalizationadd7=equalizationpadding[5][2];
            equalizationadd8=equalizationpadding[5][3];
            equalizationadd9=equalizationpadding[5][4];
        end
        138:begin
            equalizationadd1=equalizationpadding[3][3];
            equalizationadd2=equalizationpadding[3][4];
            equalizationadd3=equalizationpadding[3][5];
            equalizationadd4=equalizationpadding[4][3];
            equalizationadd5=equalizationpadding[4][4];
            equalizationadd6=equalizationpadding[4][5];
            equalizationadd7=equalizationpadding[5][3];
            equalizationadd8=equalizationpadding[5][4];
            equalizationadd9=equalizationpadding[5][5];
        end
        8'd149:begin
            equalizationadd1=normmax2;
            equalizationadd2=normmin2;
            equalizationadd3=0;
            equalizationadd4=0;
            equalizationadd5=0;
            equalizationadd6=0;
            equalizationadd7=0;
            equalizationadd8=0;
            equalizationadd9=0;
        end
        8'd150:begin
            equalizationadd1=fully2[0];
            equalizationadd2=normmin2;
            equalizationadd3=0;
            equalizationadd4=0;
            equalizationadd5=0;
            equalizationadd6=0;
            equalizationadd7=0;
            equalizationadd8=0;
            equalizationadd9=0;
        end
        8'd151:begin
            equalizationadd1=fully2[1];
            equalizationadd2=normmin2;
            equalizationadd3=0;
            equalizationadd4=0;
            equalizationadd5=0;
            equalizationadd6=0;
            equalizationadd7=0;
            equalizationadd8=0;
            equalizationadd9=0;
        end
        8'd152:begin
            equalizationadd1=fully2[2];
            equalizationadd2=normmin2;
            equalizationadd3=0;
            equalizationadd4=0;
            equalizationadd5=0;
            equalizationadd6=0;
            equalizationadd7=0;
            equalizationadd8=0;
            equalizationadd9=0;
        end
        8'd153:begin
            equalizationadd1=fully2[3];
            equalizationadd2=normmin2;
            equalizationadd3=0;
            equalizationadd4=0;
            equalizationadd5=0;
            equalizationadd6=0;
            equalizationadd7=0;
            equalizationadd8=0;
            equalizationadd9=0;
        end
        8'd159:begin
            equalizationadd1=vector1[0];
            equalizationadd2={!vector2[0][31],vector2[0][30:0]};
            equalizationadd3=0;
            equalizationadd4=0;
            equalizationadd5=0;
            equalizationadd6=0;
            equalizationadd7=0;
            equalizationadd8=0;
            equalizationadd9=0;
        end
        8'd161:begin
            equalizationadd1=vector1[1];
            equalizationadd2={!vector2[1][31],vector2[1][30:0]};
            equalizationadd3=0;
            equalizationadd4=0;
            equalizationadd5=0;
            equalizationadd6=0;
            equalizationadd7=0;
            equalizationadd8=0;
            equalizationadd9=0;
        end
        8'd163:begin
            equalizationadd1=vector1[2];
            equalizationadd2={!vector2[2][31],vector2[2][30:0]};
            equalizationadd3=0;
            equalizationadd4=0;
            equalizationadd5=0;
            equalizationadd6=0;
            equalizationadd7=0;
            equalizationadd8=0;
            equalizationadd9=0;
        end
        8'd165:begin
            equalizationadd1=vector1[3];
            equalizationadd2={!vector2[3][31],vector2[3][30:0]};
            equalizationadd3=0;
            equalizationadd4=0;
            equalizationadd5=0;
            equalizationadd6=0;
            equalizationadd7=0;
            equalizationadd8=0;
            equalizationadd9=0;
        end
        8'd166:begin
            equalizationadd1=distancetmp1;
            equalizationadd2=distancetmp2;
            equalizationadd3=distancetmp3;
            equalizationadd4=distancetmp4;
            equalizationadd5=0;
            equalizationadd6=0;
            equalizationadd7=0;
            equalizationadd8=0;
            equalizationadd9=0;
        end
        default:begin
            equalizationadd1=0;
            equalizationadd2=0;
            equalizationadd3=0;
            equalizationadd4=0;
            equalizationadd5=0;
            equalizationadd6=0;
            equalizationadd7=0;
            equalizationadd8=0;
            equalizationadd9=0;
        end
    endcase
end
assign div9ctrl=~((clkcnt>=72&&clkcnt<=87)||(clkcnt>=123&&clkcnt<=166));
GATED_OR div9clk(.CLOCK(clk),.SLEEP_CTRL(cg_en&&div9ctrl),.RST_N(rst_n),.CLOCK_GATED(gclk15));
always @(posedge gclk15 or negedge rst_n) begin
    if (!rst_n) beforediv9<=0;
    else begin
        beforediv9<=equalizationsum4;
    end
end
assign div1ctrl=~((clkcnt>=73&&clkcnt<=88)||(clkcnt>=124&&clkcnt<=167));
GATED_OR div1clk(.CLOCK(clk),.SLEEP_CTRL(cg_en&&div1ctrl),.RST_N(rst_n),.CLOCK_GATED(gclk16));
DW_fp_div div2(.a(divtmpa),.b(divtmpb),.rnd(3'b0),.z(divans));
always @(posedge gclk16 or negedge rst_n) begin
    if (!rst_n) begin
        divtmpa<=0;
        divtmpb<=0;
    end
    else begin
        case (clkcnt)
            8'd73:begin
                divtmpa<=beforediv9;
                divtmpb<=nine;
            end
            8'd74:begin
                divtmpa<=beforediv9;
                divtmpb<=nine;
            end
            8'd75:begin
                divtmpa<=beforediv9;
                divtmpb<=nine;
            end
            8'd76:begin
                divtmpa<=beforediv9;
                divtmpb<=nine;
            end
            8'd77:begin
                divtmpa<=beforediv9;
                divtmpb<=nine;
            end
            8'd78:begin
                divtmpa<=beforediv9;
                divtmpb<=nine;
            end
            8'd79:begin
                divtmpa<=beforediv9;
                divtmpb<=nine;
            end
            8'd80:begin
                divtmpa<=beforediv9;
                divtmpb<=nine;
            end
            8'd81:begin
                divtmpa<=beforediv9;
                divtmpb<=nine;
            end
            8'd82:begin
                divtmpa<=beforediv9;
                divtmpb<=nine;
            end
            8'd83:begin
                divtmpa<=beforediv9;
                divtmpb<=nine;
            end
            8'd84:begin
                divtmpa<=beforediv9;
                divtmpb<=nine;
            end
            8'd85:begin
                divtmpa<=beforediv9;
                divtmpb<=nine;
            end
            8'd86:begin
                divtmpa<=beforediv9;
                divtmpb<=nine;
            end
            8'd87:begin
                divtmpa<=beforediv9;
                divtmpb<=nine;
            end
            8'd88:begin
                divtmpa<=beforediv9;
                divtmpb<=nine;
            end
            8'd124:begin
                divtmpa<=beforediv9;
                divtmpb<=nine;
            end
            8'd125:begin
                divtmpa<=beforediv9;
                divtmpb<=nine;
            end
            8'd126:begin
                divtmpa<=beforediv9;
                divtmpb<=nine;
            end
            8'd127:begin
                divtmpa<=beforediv9;
                divtmpb<=nine;
            end
            8'd128:begin
                divtmpa<=beforediv9;
                divtmpb<=nine;
            end
            8'd129:begin
                divtmpa<=beforediv9;
                divtmpb<=nine;
            end
            8'd130:begin
                divtmpa<=beforediv9;
                divtmpb<=nine;
            end
            8'd131:begin
                divtmpa<=beforediv9;
                divtmpb<=nine;
            end
            8'd132:begin
                divtmpa<=beforediv9;
                divtmpb<=nine;
            end
            8'd133:begin
                divtmpa<=beforediv9;
                divtmpb<=nine;
            end
            8'd134:begin
                divtmpa<=beforediv9;
                divtmpb<=nine;
            end
            8'd135:begin
                divtmpa<=beforediv9;
                divtmpb<=nine;
            end
            8'd136:begin
                divtmpa<=beforediv9;
                divtmpb<=nine;
            end
            8'd137:begin
                divtmpa<=beforediv9;
                divtmpb<=nine;
            end
            8'd138:begin
                divtmpa<=beforediv9;
                divtmpb<=nine;
            end
            8'd139:begin
                divtmpa<=beforediv9;
                divtmpb<=nine;
            end
        endcase
    end
end


//Maxpooling
assign cmp1ctrl=~((clkcnt>=80&&clkcnt<=91)||(clkcnt>=131&&clkcnt<=147));
GATED_OR cmp1clk(.CLOCK(clk),.SLEEP_CTRL(cg_en&&cmp1ctrl),.RST_N(rst_n),.CLOCK_GATED(gclk17));
assign cmp2ctrl=~((clkcnt>=120&&clkcnt<=125)||(clkcnt>=145&&clkcnt<=147));
GATED_OR cmp2clk(.CLOCK(clk),.SLEEP_CTRL(cg_en&&cmp2ctrl),.RST_N(rst_n),.CLOCK_GATED(gclk18));
always @(posedge gclk17 or negedge rst_n) begin
    if (!rst_n) begin
        tmpcmpa<=0;
        tmpcmpb<=0;
    end
    else begin
        case (clkcnt)
            8'd80:begin
                tmpcmpa<=futuremmap1[0][0];
                tmpcmpb<=futuremmap1[0][1];
            end 
            8'd81:begin
                tmpcmpa<=max;
                tmpcmpb<=futuremmap1[1][0];
            end
            8'd82:begin
                tmpcmpa<=max;
                tmpcmpb<=futuremmap1[1][1];
            end
            8'd83:begin
                tmpcmpa<=futuremmap1[0][2];
                tmpcmpb<=futuremmap1[0][3];
            end 
            8'd84:begin
                tmpcmpa<=max;
                tmpcmpb<=futuremmap1[1][2];
            end
            8'd85:begin
                tmpcmpa<=max;
                tmpcmpb<=futuremmap1[1][3];
            end
            8'd86:begin
                tmpcmpa<=futuremmap1[2][0];
                tmpcmpb<=futuremmap1[2][1];
            end 
            8'd87:begin
                tmpcmpa<=max;
                tmpcmpb<=futuremmap1[3][0];
            end
            8'd88:begin
                tmpcmpa<=max;
                tmpcmpb<=futuremmap1[3][1];
            end
            8'd89:begin
                tmpcmpa<=futuremmap1[2][2];
                tmpcmpb<=futuremmap1[2][3];
            end 
            8'd90:begin
                tmpcmpa<=max;
                tmpcmpb<=futuremmap1[3][2];
            end
            8'd91:begin
                tmpcmpa<=max;
                tmpcmpb<=futuremmap1[3][3];
            end
            8'd131:begin
                tmpcmpa<=futuremmap2[0][0];
                tmpcmpb<=futuremmap2[0][1];
            end 
            8'd132:begin
                tmpcmpa<=max;
                tmpcmpb<=futuremmap2[1][0];
            end
            8'd133:begin
                tmpcmpa<=max;
                tmpcmpb<=futuremmap2[1][1];
            end
            8'd134:begin
                tmpcmpa<=futuremmap2[0][2];
                tmpcmpb<=futuremmap2[0][3];
            end 
            8'd135:begin
                tmpcmpa<=max;
                tmpcmpb<=futuremmap2[1][2];
            end
            8'd136:begin
                tmpcmpa<=max;
                tmpcmpb<=futuremmap2[1][3];
            end
            8'd137:begin
                tmpcmpa<=futuremmap2[2][0];
                tmpcmpb<=futuremmap2[2][1];
            end 
            8'd138:begin
                tmpcmpa<=max;
                tmpcmpb<=futuremmap2[3][0];
            end
            8'd139:begin
                tmpcmpa<=max;
                tmpcmpb<=futuremmap2[3][1];
            end
            8'd140:begin
                tmpcmpa<=futuremmap2[2][2];
                tmpcmpb<=futuremmap2[2][3];
            end 
            8'd141:begin
                tmpcmpa<=max;
                tmpcmpb<=futuremmap2[3][2];
            end
            8'd142:begin
                tmpcmpa<=max;
                tmpcmpb<=futuremmap2[3][3];
            end
            8'd145:begin
                tmpcmpa<=fully2[0];
                tmpcmpb<=fully2[1];
            end
            8'd146:begin
                tmpcmpa<=max;
                tmpcmpb<=fully2[2];
            end
            8'd147:begin
                tmpcmpa<=max;
                tmpcmpb<=fully2[3];
            end
        endcase
    end
end
always @(posedge gclk18 or negedge rst_n) begin
    if (!rst_n) begin
        tmpcmp1<=0;
        tmpcmp2<=0;
    end
    else begin
        case (clkcnt)
            8'd120:begin
                tmpcmp1<=fully1[0];
                tmpcmp2<=fully1[1];
            end
            8'd121:begin
                tmpcmp1<=max2;
                tmpcmp2<=fully1[2];
            end
            8'd122:begin
                tmpcmp1<=max2;
                tmpcmp2<=fully1[3];
            end
            8'd123:begin
                tmpcmp1<=fully1[0];
                tmpcmp2<=fully1[1];
            end
            8'd124:begin
                tmpcmp1<=min2;
                tmpcmp2<=fully1[2];
            end
            8'd125:begin
                tmpcmp1<=min2;
                tmpcmp2<=fully1[3];
            end
            8'd145:begin
                tmpcmp1<=fully2[0];
                tmpcmp2<=fully2[1];
            end
            8'd146:begin
                tmpcmp1<=min2;
                tmpcmp2<=fully2[2];
            end
            8'd147:begin
                tmpcmp1<=min2;
                tmpcmp2<=fully2[3];
            end
        endcase
    end
end
DW_fp_cmp cmp1(.a(tmpcmpa),.b(tmpcmpb),.zctr(1'b1),.z0(max),.z1(min));
DW_fp_cmp cmp2(.a(tmpcmp1),.b(tmpcmp2),.zctr(1'b1),.z0(max2),.z1(min2));
assign maxpoolctrl=~(clkcnt==83||clkcnt==86||clkcnt==89||clkcnt==92);
GATED_OR maxpoolclk(.CLOCK(clk),.SLEEP_CTRL(cg_en&&maxpoolctrl),.RST_N(rst_n),.CLOCK_GATED(gclk19));
assign m2=~(clkcnt==134||clkcnt==137||clkcnt==140||clkcnt==143);
GATED_OR maxpoffolclk(.CLOCK(clk),.SLEEP_CTRL(cg_en&&m2),.RST_N(rst_n),.CLOCK_GATED(g9));
always @(posedge gclk19 or negedge rst_n) begin
    if (!rst_n) begin
        for (integer i =0 ;i<2 ;i=i+1 ) begin
            for (integer j =0 ;j<2 ;j=j+1 ) begin
                maxpool1[i][j]<=0;
            end
        end
    end
    else begin
        case (clkcnt)
            8'd83:maxpool1[0][0]<=max;
            8'd86:maxpool1[0][1]<=max;
            8'd89:maxpool1[1][0]<=max;
            8'd92:maxpool1[1][1]<=max; 
        endcase
    end
end
always @(posedge g9 or negedge rst_n) begin
    if (!rst_n) begin
        for (integer i =0 ;i<2 ;i=i+1 ) begin
            for (integer j =0 ;j<2 ;j=j+1 ) begin
                maxpool2[i][j]<=0;
            end
        end
    end
    else begin
        case (clkcnt) 
            8'd134:maxpool2[0][0]<=max;
            8'd137:maxpool2[0][1]<=max;
            8'd140:maxpool2[1][0]<=max;
            8'd143:maxpool2[1][1]<=max;
        endcase
    end
end
//Fully connected
assign fullyctrl=~(clkcnt==119||clkcnt==120);
GATED_OR fullyclk(.CLOCK(clk),.SLEEP_CTRL(cg_en&&fullyctrl),.RST_N(rst_n),.CLOCK_GATED(gclk20));
assign f2=~(clkcnt==144||clkcnt==145);
GATED_OR fullyfdclk(.CLOCK(clk),.SLEEP_CTRL(cg_en&&f2),.RST_N(rst_n),.CLOCK_GATED(g10));
always @(posedge gclk20 or negedge rst_n) begin
    if (!rst_n) begin
        for (integer i =0 ;i<4 ;i=i+1 ) begin
            fully1[i]<=0;
        end
    end
    else begin
        case (clkcnt)
            8'd119:begin
                fully1[0]<=sum1;
                fully1[1]<=sum2;
            end
            8'd120:begin
                fully1[2]<=sum1;
                fully1[3]<=sum2;
            end
        endcase
    end
end
always @(posedge g10 or negedge rst_n) begin
    if (!rst_n) begin
        for (integer i =0 ;i<4 ;i=i+1 ) begin
            fully2[i]<=0;
        end
    end
    else begin
        case (clkcnt)
            8'd144:begin
                fully2[0]<=sum1;
                fully2[1]<=sum2;
            end
            8'd145:begin
                fully2[2]<=sum1;
                fully2[3]<=sum2; 
            end
        endcase
    end
end
//Min-Max Normalization and Activation Function
assign normmaxminctrl=~(clkcnt==123||clkcnt==126||clkcnt==148);
GATED_OR normclk1(.CLOCK(clk),.SLEEP_CTRL(cg_en&&normmaxminctrl),.RST_N(rst_n),.CLOCK_GATED(gclk21));
always @(posedge gclk21 or negedge rst_n) begin
    if (!rst_n) begin
        normmax1<=0;
        normmax2<=0;
        normmin1<=0;
        normmin2<=0;
    end
    else begin
        case (clkcnt)
            8'd123:normmax1<=max2;
            8'd126:normmin1<={!min2[31],min2[30:0]}; //改signed bit用加法
            8'd148:begin
                normmax2<=max;
                normmin2<={!min2[31],min2[30:0]};
            end//改signed bit用加法
        endcase
    end
end
assign xsubctrl=~(clkcnt==128||clkcnt==149);
GATED_OR normclk2(.CLOCK(clk),.SLEEP_CTRL(cg_en&&xsubctrl),.RST_N(rst_n),.CLOCK_GATED(gclk22));
always @(posedge gclk22 or negedge rst_n) begin
    if (!rst_n) begin
        xmaxsubxmin1<=0;
        xmaxsubxmin2<=0;
    end
    else begin
        case (clkcnt)
            8'd128:xmaxsubxmin1<=convtmp3; 
            8'd149:xmaxsubxmin2<=equalizationsum1;
        endcase
    end
end
assign div2ctrl=~((clkcnt>=129&&clkcnt<=132)||(clkcnt>=139&&clkcnt<=142)||(clkcnt>=150&&clkcnt<=163));
GATED_OR divclk2(.CLOCK(clk),.SLEEP_CTRL(cg_en&&div2ctrl),.RST_N(rst_n),.CLOCK_GATED(gclk23));
always @(posedge gclk23 or negedge rst_n) begin
    if (!rst_n) begin
        divtmp1<=0;
        divtmp2<=0;
    end
    else begin
        case (clkcnt)
            8'd129:begin
                divtmp1<=convtmp3;
                divtmp2<=xmaxsubxmin1;
            end
            8'd130:begin
                divtmp1<=convtmp3;
                divtmp2<=xmaxsubxmin1;
            end
            8'd131:begin
                divtmp1<=convtmp3;
                divtmp2<=xmaxsubxmin1;
            end
            8'd132:begin
                divtmp1<=convtmp3;
                divtmp2<=xmaxsubxmin1;
            end
            8'd150:begin
                divtmp1<=equalizationsum1;
                divtmp2<=xmaxsubxmin2;
            end
            8'd151:begin
                divtmp1<=equalizationsum1;
                divtmp2<=xmaxsubxmin2;
            end
            8'd152:begin
                divtmp1<=equalizationsum1;
                divtmp2<=xmaxsubxmin2;
            end
            8'd153:begin
                divtmp1<=equalizationsum1;
                divtmp2<=xmaxsubxmin2;
            end
            8'd139:begin
                if(optreg[1]) divtmp1<=expsubexp1_1;
                else divtmp1<=one;
                divtmp2<=convtmp;
            end
            8'd140:begin
                if(optreg[1]) divtmp1<=expsubexp1_2;
                else divtmp1<=one;
                divtmp2<=convtmp3;
            end
            8'd141:begin
                if(optreg[1]) divtmp1<=expsubexp1_3;
                else divtmp1<=one;
                divtmp2<=convtmp3;
            end
            8'd142:begin
                if(optreg[1]) divtmp1<=expsubexp1_4;
                else divtmp1<=one;
                divtmp2<=convtmp3;
            end
            8'd157:begin
                if(optreg[1]) divtmp1<=convtmp;
                else divtmp1<=one;
                divtmp2<=convtmp3;
            end
            8'd159:begin
                if(optreg[1]) divtmp1<=convtmp;
                else divtmp1<=one;
                divtmp2<=convtmp3;
            end
            8'd161:begin
                if(optreg[1]) divtmp1<=convtmp;
                else divtmp1<=one;
                divtmp2<=convtmp3;
            end
            8'd163:begin
                if(optreg[1]) divtmp1<=convtmp;
                else divtmp1<=one;
                divtmp2<=convtmp3;
            end
        endcase
    end
end
assign normctrl=~((clkcnt>=130&&clkcnt<=133));
GATED_OR normclk3(.CLOCK(clk),.SLEEP_CTRL(cg_en&&normctrl),.RST_N(rst_n),.CLOCK_GATED(gclk24));
assign n2=~((clkcnt>=151&&clkcnt<=154));
GATED_OR norfsfmclk3(.CLOCK(clk),.SLEEP_CTRL(cg_en&&n2),.RST_N(rst_n),.CLOCK_GATED(g11));
always @(posedge gclk24 or negedge rst_n) begin
    if (!rst_n) begin
        for (integer i=0 ;i<4 ;i=i+1 ) begin
            norm1[i]<=0;
        end
    end
    else begin
        case (clkcnt)
            8'd130:norm1[0]<=divanswer;
            8'd131:norm1[1]<=divanswer;
            8'd132:norm1[2]<=divanswer;
            8'd133:norm1[3]<=divanswer;
        endcase
    end
end
always @(posedge g11 or negedge rst_n) begin
    if (!rst_n) begin
        for (integer i=0 ;i<4 ;i=i+1 ) begin
            norm2[i]<=0;
        end
    end
    else begin
        case (clkcnt)
            8'd151:norm2[0]<=divanswer;
            8'd152:norm2[1]<=divanswer;
            8'd153:norm2[2]<=divanswer;
            8'd154:norm2[3]<=divanswer;
        endcase
    end
end
DW_fp_div div1(.a(divtmp1),.b(divtmp2),.rnd(3'b0),.z(divanswer));
assign expctrl1=~((clkcnt>=131&&clkcnt<=138)||(clkcnt>=153&&clkcnt<=160));
GATED_OR expclk122(.CLOCK(clk),.SLEEP_CTRL(cg_en&&expctrl1),.RST_N(rst_n),.CLOCK_GATED(gclk25));
always @(posedge gclk25 or negedge rst_n) begin
    if (!rst_n) begin
        exptmp<=0;
    end
    else begin
        case (clkcnt)
            8'd131:exptmp<=norm1[0];
            8'd132:exptmp<={!norm1[0][31],norm1[0][30:0]};
            8'd133:exptmp<=norm1[1];
            8'd134:exptmp<={!norm1[1][31],norm1[1][30:0]};
            8'd135:exptmp<=norm1[2];
            8'd136:exptmp<={!norm1[2][31],norm1[2][30:0]};
            8'd137:exptmp<=norm1[3];
            8'd138:exptmp<={!norm1[3][31],norm1[3][30:0]};
            8'd153:exptmp<=norm2[0];
            8'd154:exptmp<={!norm2[0][31],norm2[0][30:0]};
            8'd155:exptmp<=norm2[1];
            8'd156:exptmp<={!norm2[1][31],norm2[1][30:0]};
            8'd157:exptmp<=norm2[2];
            8'd158:exptmp<={!norm2[2][31],norm2[2][30:0]};
            8'd159:exptmp<=norm2[3];
            8'd160:exptmp<={!norm2[3][31],norm2[3][30:0]};
        endcase
    end
end
assign exp1=~((clkcnt>=132&&clkcnt<=135));
GATED_OR expclk12fd2(.CLOCK(clk),.SLEEP_CTRL(cg_en&&exp1),.RST_N(rst_n),.CLOCK_GATED(expclk1));
assign exp2=~((clkcnt>=136&&clkcnt<=139));
GATED_OR expclk12f2(.CLOCK(clk),.SLEEP_CTRL(cg_en&&exp2),.RST_N(rst_n),.CLOCK_GATED(expclk2));
assign exp3=~((clkcnt>=154&&clkcnt<=157));
GATED_OR expclk1ff2fd2(.CLOCK(clk),.SLEEP_CTRL(cg_en&&exp3),.RST_N(rst_n),.CLOCK_GATED(expclk3));
assign exp4=~((clkcnt>=158&&clkcnt<=161));
GATED_OR expclks12f2(.CLOCK(clk),.SLEEP_CTRL(cg_en&&exp4),.RST_N(rst_n),.CLOCK_GATED(expclk4));
always @(posedge expclk1 or negedge rst_n) begin
    if (!rst_n) begin
        exp1_1pos<=0;
        exp1_1neg<=0;
        exp1_2pos<=0;
        exp1_2neg<=0;
    end
    else begin
        case (clkcnt)
            8'd132:exp1_1pos<=expout; 
            8'd133:exp1_1neg<=expout;
            8'd134:exp1_2pos<=expout;
            8'd135:exp1_2neg<=expout;
        endcase
    end
end
always @(posedge expclk2 or negedge rst_n) begin
    if (!rst_n) begin
        exp1_3pos<=0;
        exp1_3neg<=0;
        exp1_4pos<=0;
        exp1_4neg<=0;
    end
    else begin
        case (clkcnt)
            8'd136:exp1_3pos<=expout;
            8'd137:exp1_3neg<=expout;
            8'd138:exp1_4pos<=expout;
            8'd139:exp1_4neg<=expout;
        endcase
    end
end
always @(posedge expclk3 or negedge rst_n) begin
    if (!rst_n) begin
        exp2_1pos<=0;
        exp2_1neg<=0;
        exp2_2pos<=0;
        exp2_2neg<=0;
    end
    else begin
        case (clkcnt)
            8'd154:exp2_1pos<=expout; 
            8'd155:exp2_1neg<=expout;
            8'd156:exp2_2pos<=expout;
            8'd157:exp2_2neg<=expout;
        endcase
    end
end
always @(posedge expclk4 or negedge rst_n) begin
    if (!rst_n) begin
        exp2_3pos<=0;
        exp2_3neg<=0;
        exp2_4pos<=0;
        exp2_4neg<=0;
    end
    else begin
        case (clkcnt)
            8'd158:exp2_3pos<=expout;
            8'd159:exp2_3neg<=expout;
            8'd160:exp2_4pos<=expout;
            8'd161:exp2_4neg<=expout;
        endcase
    end
end
assign expctrl3=~(clkcnt==135||clkcnt==137||clkcnt==139||clkcnt==141);
GATED_OR expclk223(.CLOCK(clk),.SLEEP_CTRL(cg_en&&expctrl3),.RST_N(rst_n),.CLOCK_GATED(gclk27));
always @(posedge gclk27 or negedge rst_n) begin
    if (!rst_n) begin
        expsubexp1_1<=0;
        expsubexp1_2<=0;
        expsubexp1_3<=0;
        expsubexp1_4<=0;
    end
    else begin
        case (clkcnt)
            8'd135:expsubexp1_1<=convtmp3;
            8'd137:expsubexp1_2<=convtmp3;
            8'd139:expsubexp1_3<=convtmp3;
            8'd141:expsubexp1_4<=convtmp;  
        endcase
    end
end
assign vectorctrl1=~((clkcnt>=140&&clkcnt<=143));
GATED_OR vecclk(.CLOCK(clk),.SLEEP_CTRL(cg_en&&vectorctrl1),.RST_N(rst_n),.CLOCK_GATED(gclk28));
assign vectorctrl2=~((clkcnt>=158&&clkcnt<=164));
GATED_OR vecclffk(.CLOCK(clk),.SLEEP_CTRL(cg_en&&vectorctrl2),.RST_N(rst_n),.CLOCK_GATED(gclk35));
always @(posedge gclk28 or negedge rst_n) begin
    if (!rst_n) begin
        for (integer i =0 ;i<4 ;i=i+1 ) begin
            vector1[i]<=0;
        end
    end
    else begin
        case (clkcnt)
            8'd140:vector1[0]<=divanswer; 
            8'd141:vector1[1]<=divanswer;
            8'd142:vector1[2]<=divanswer;
            8'd143:vector1[3]<=divanswer;
        endcase
    end
end
always @(posedge gclk35 or negedge rst_n) begin
    if (!rst_n) begin
        for (integer i =0 ;i<4 ;i=i+1 ) begin
            vector2[i]<=0;
        end
    end
    else begin
        case (clkcnt)
            8'd158:vector2[0]<=divanswer; 
            8'd160:vector2[1]<=divanswer;
            8'd162:vector2[2]<=divanswer;
            8'd164:vector2[3]<=divanswer;
        endcase
    end
end
DW_fp_exp #(inst_sig_width,inst_exp_width,1'b1) exp123(.a(exptmp),.z(expout));
//L1 distance
assign distancectrl=~(clkcnt==159||clkcnt==161||clkcnt==163||clkcnt==165||clkcnt==166);
GATED_OR distanceclk(.CLOCK(clk),.SLEEP_CTRL(cg_en&&distancectrl),.RST_N(rst_n),.CLOCK_GATED(gclk29));
always @(posedge gclk29 or negedge rst_n) begin
    if (!rst_n) begin
        distancetmp1<=0;
        distancetmp2<=0;
        distancetmp3<=0;
        distancetmp4<=0;
        distancetmp5<=0;
    end
    else begin
        case (clkcnt)
            8'd159:distancetmp1<={1'b0,equalizationsum1[30:0]};
            8'd161:distancetmp2<={1'b0,equalizationsum1[30:0]};
            8'd163:distancetmp3<={1'b0,equalizationsum1[30:0]};
            8'd165:distancetmp4<={1'b0,equalizationsum1[30:0]};
            8'd166:distancetmp5<=equalizationsum4;
        endcase
    end
end
wire imgctrl[0:95];
wire optctrl;
reg optclk;
reg imageclk[0:95];
wire kerctrl[0:26];
reg kerclk[0:26];
wire weictrl[0:3];
reg weiclk[0:3];
genvar i;
//Opt Input
assign optctrl=~(clkcnt==0);
GATED_OR distvvanceclk(.CLOCK(clk),.SLEEP_CTRL(cg_en&&optctrl),.RST_N(rst_n),.CLOCK_GATED(optclk));
always @(posedge optclk or negedge rst_n) begin
    if (!rst_n) optreg<=0;
    else begin
        if (in_valid&&clkcnt==0) begin
            optreg<=Opt;
        end
    end
end
//Image input
generate
    for(i = 0; i < 96; i = i+1) begin
        assign imgctrl[i]=~(clkcnt>=0&&clkcnt<=95);
        GATED_OR ddddk(.CLOCK(clk),.SLEEP_CTRL(cg_en&&imgctrl[i]),.RST_N(rst_n),.CLOCK_GATED(imageclk[i]));
        always @(posedge imageclk[i] or negedge rst_n) begin
            if(!rst_n) image[i] <= 32'b0;
            else if(in_valid && clkcnt == i) image[i] <= Img;
        end
    end
endgenerate

// read Kernel
generate
    for(i = 0; i < 27; i = i+1) begin
        assign kerctrl[i]=~(clkcnt>=0&&clkcnt<=26);
        GATED_OR ddddfk(.CLOCK(clk),.SLEEP_CTRL(cg_en&&kerctrl[i]),.RST_N(rst_n),.CLOCK_GATED(kerclk[i]));
        always @(posedge kerclk[i] or negedge rst_n) begin
            if(!rst_n) kerneltmp[i] <= 32'b0;
            else if(in_valid && clkcnt == i) kerneltmp[i] <= Kernel;
        end
    end
endgenerate

// read Weight
generate
    for(i = 0; i < 4; i = i+1) begin
        assign weictrl[i]=~(clkcnt>=0&&clkcnt<=3);
        GATED_OR ddddffk(.CLOCK(clk),.SLEEP_CTRL(cg_en&&weictrl[i]),.RST_N(rst_n),.CLOCK_GATED(weiclk[i]));
        always @(posedge weiclk[i] or negedge rst_n) begin
            if(!rst_n) weighttmp[i] <= 32'b0;
            else if(in_valid && clkcnt == i) weighttmp[i] <= Weight;
        end
    end
endgenerate
//out_valid
always @(*) begin
    if (clkcnt==1095) begin
        out_valid=1'b1;
    end
    else out_valid=1'b0;
end
//out
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        out<=0;
    end
    else begin
        if (clkcnt==1094) begin
            out<=distancetmp5;
        end
        else out<=0;
    end
end
endmodule

module padding (image4x4,opt_0,image6x6);
input [31:0]image4x4[0:15];
input opt_0;
output reg [31:0]image6x6[0:5][0:5];
always @(*) begin
    image6x6[1][1]=image4x4[0];
    image6x6[1][2]=image4x4[1];
    image6x6[1][3]=image4x4[2];
    image6x6[1][4]=image4x4[3];
    image6x6[2][1]=image4x4[4];
    image6x6[2][2]=image4x4[5];
    image6x6[2][3]=image4x4[6];
    image6x6[2][4]=image4x4[7];
    image6x6[3][1]=image4x4[8];
    image6x6[3][2]=image4x4[9];
    image6x6[3][3]=image4x4[10];
    image6x6[3][4]=image4x4[11];
    image6x6[4][1]=image4x4[12];
    image6x6[4][2]=image4x4[13];
    image6x6[4][3]=image4x4[14];
    image6x6[4][4]=image4x4[15];
    image6x6[0][0]=opt_0?0:image4x4[0];
    image6x6[0][1]=opt_0?0:image4x4[0];
    image6x6[0][2]=opt_0?0:image4x4[1];
    image6x6[0][3]=opt_0?0:image4x4[2];
    image6x6[0][4]=opt_0?0:image4x4[3];
    image6x6[0][5]=opt_0?0:image4x4[3];
    image6x6[1][0]=opt_0?0:image4x4[0];
    image6x6[1][5]=opt_0?0:image4x4[3];
    image6x6[2][0]=opt_0?0:image4x4[4];
    image6x6[2][5]=opt_0?0:image4x4[7];
    image6x6[3][0]=opt_0?0:image4x4[8];
    image6x6[3][5]=opt_0?0:image4x4[11];
    image6x6[4][0]=opt_0?0:image4x4[12];
    image6x6[4][5]=opt_0?0:image4x4[15];
    image6x6[5][0]=opt_0?0:image4x4[12];
    image6x6[5][1]=opt_0?0:image4x4[12];
    image6x6[5][2]=opt_0?0:image4x4[13];
    image6x6[5][3]=opt_0?0:image4x4[14];
    image6x6[5][4]=opt_0?0:image4x4[15];
    image6x6[5][5]=opt_0?0:image4x4[15];
end
endmodule
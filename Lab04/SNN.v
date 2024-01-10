//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   (C) Copyright Laboratory System Integration and Silicon Implementation
//   All Right Reserved
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   ICLAB 2023 Fall
//   Lab04 Exercise		: Siamese Neural Network 
//   Author     		: Jia-Yu Lee (maggie8905121@gmail.com)
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   File Name   : SNN.v
//   Module Name : SNN
//   Release version : V1.0 (Release Date: 2023-09)
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################

//synopsys translate_off
// `include "/usr/cad/synopsys/synthesis/cur/dw/sim_ver/DW_fp_mult.v"
//synopsys translate_on


module SNN(
    //Input Port
    clk,
    rst_n,
    in_valid,
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
reg [31:0]exptmp,expout;
reg [31:0]exp1_1pos,exp1_1neg,exp1_2pos,exp1_2neg,exp1_3pos,exp1_3neg,exp1_4pos,exp1_4neg;
reg [31:0]exp2_1pos,exp2_1neg,exp2_2pos,exp2_2neg,exp2_3pos,exp2_3neg,exp2_4pos,exp2_4neg;
reg [31:0]expsubexp1_1,expsubexp1_2,expsubexp1_3,expsubexp1_4;
reg [31:0]distancetmp1,distancetmp2,distancetmp3,distancetmp4;
reg [7:0]clkcnt;
reg [4:0]cnt16;
wire [31:0]one;
reg [31:0]tmpcmp1,tmpcmp2,max2,min2;
reg [31:0]paddinginput[0:15];

assign one=32'b00111111100000000000000000000000;
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
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (integer i =0 ;i<16 ;i=i+1 ) begin
            paddinginput[i]<=0;
        end
    end 
    else begin
        case (clkcnt)
            8'd16:paddinginput<=image[0:15];
            8'd33:paddinginput<=image[16:31];
            8'd50:paddinginput<=image[32:47];
            8'd67:paddinginput<=image[48:63];
            8'd84:paddinginput<=image[64:79];
            8'd101:paddinginput<=image[80:95]; 
        endcase
    end
end
padding p1(.image4x4(paddinginput),.opt_0(optreg[0]),.image6x6(tmppaddingimage));
//Convolution
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (integer i=0 ;i<3 ;i=i+1 ) begin
            for (integer j = 0;j<3 ;j=j+1 ) begin
                tmpkernel[i][j]<=0;
            end
        end
    end
    else begin
        case (clkcnt)
            8'd16:begin
                tmpkernel<=kerneltmp[0:8];
            end
            8'd33:begin
                tmpkernel<=kerneltmp[9:17];
            end
            8'd50:begin
                tmpkernel<=kerneltmp[18:26];
            end
            8'd67:begin
                tmpkernel<=kerneltmp[0:8];
            end
            8'd84:begin
                tmpkernel<=kerneltmp[9:17];
            end
            8'd101:begin
                tmpkernel<=kerneltmp[18:26];
            end
        endcase
    end
end
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        cnt16<=0;
    end
    else begin
        if (clkcnt>16) begin
            if (cnt16==16) begin
                cnt16<=0;
            end
            else cnt16<=cnt16+1;
        end
        else cnt16<=0;
    end
end
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        tmp1<=0;
        tmp2<=0;
        tmp3<=0;
        tmp4<=0;
        tmp5<=0;
        tmp6<=0;
        tmp7<=0;
        tmp8<=0;
        tmp9<=0;
        tmp10<=0;
        tmp11<=0;
        tmp12<=0;
        tmp13<=0;
        tmp14<=0;
        tmp15<=0;
        tmp16<=0;
        tmp17<=0;
        tmp18<=0;
    end
    else begin
        if (clkcnt<=117) begin
            case (cnt16)
                5'd0:begin
                    tmp1<=tmppaddingimage[0][0];
                    tmp2<=tmpkernel[0];
                    tmp3<=tmppaddingimage[0][1];
                    tmp4<=tmpkernel[1];
                    tmp5<=tmppaddingimage[0][2];
                    tmp6<=tmpkernel[2];
                    tmp7<=tmppaddingimage[1][0];
                    tmp8<=tmpkernel[3];
                    tmp9<=tmppaddingimage[1][1];
                    tmp10<=tmpkernel[4];
                    tmp11<=tmppaddingimage[1][2];
                    tmp12<=tmpkernel[5];
                    tmp13<=tmppaddingimage[2][0];
                    tmp14<=tmpkernel[6];
                    tmp15<=tmppaddingimage[2][1];
                    tmp16<=tmpkernel[7];
                    tmp17<=tmppaddingimage[2][2];
                    tmp18<=tmpkernel[8];
                end
                5'd1:begin
                    tmp1<=tmppaddingimage[0][1];
                    tmp2<=tmpkernel[0];
                    tmp3<=tmppaddingimage[0][2];
                    tmp4<=tmpkernel[1];
                    tmp5<=tmppaddingimage[0][3];
                    tmp6<=tmpkernel[2];
                    tmp7<=tmppaddingimage[1][1];
                    tmp8<=tmpkernel[3];
                    tmp9<=tmppaddingimage[1][2];
                    tmp10<=tmpkernel[4];
                    tmp11<=tmppaddingimage[1][3];
                    tmp12<=tmpkernel[5];
                    tmp13<=tmppaddingimage[2][1];
                    tmp14<=tmpkernel[6];
                    tmp15<=tmppaddingimage[2][2];
                    tmp16<=tmpkernel[7];
                    tmp17<=tmppaddingimage[2][3];
                    tmp18<=tmpkernel[8];
                end
                5'd2:begin
                    tmp1<=tmppaddingimage[0][2];
                    tmp2<=tmpkernel[0];
                    tmp3<=tmppaddingimage[0][3];
                    tmp4<=tmpkernel[1];
                    tmp5<=tmppaddingimage[0][4];
                    tmp6<=tmpkernel[2];
                    tmp7<=tmppaddingimage[1][2];
                    tmp8<=tmpkernel[3];
                    tmp9<=tmppaddingimage[1][3];
                    tmp10<=tmpkernel[4];
                    tmp11<=tmppaddingimage[1][4];
                    tmp12<=tmpkernel[5];
                    tmp13<=tmppaddingimage[2][2];
                    tmp14<=tmpkernel[6];
                    tmp15<=tmppaddingimage[2][3];
                    tmp16<=tmpkernel[7];
                    tmp17<=tmppaddingimage[2][4];
                    tmp18<=tmpkernel[8];
                end
                5'd3:begin
                    tmp1<=tmppaddingimage[0][3];
                    tmp2<=tmpkernel[0];
                    tmp3<=tmppaddingimage[0][4];
                    tmp4<=tmpkernel[1];
                    tmp5<=tmppaddingimage[0][5];
                    tmp6<=tmpkernel[2];
                    tmp7<=tmppaddingimage[1][3];
                    tmp8<=tmpkernel[3];
                    tmp9<=tmppaddingimage[1][4];
                    tmp10<=tmpkernel[4];
                    tmp11<=tmppaddingimage[1][5];
                    tmp12<=tmpkernel[5];
                    tmp13<=tmppaddingimage[2][3];
                    tmp14<=tmpkernel[6];
                    tmp15<=tmppaddingimage[2][4];
                    tmp16<=tmpkernel[7];
                    tmp17<=tmppaddingimage[2][5];
                    tmp18<=tmpkernel[8];
                end
                5'd4:begin
                    tmp1<=tmppaddingimage[1][0];
                    tmp2<=tmpkernel[0];
                    tmp3<=tmppaddingimage[1][1];
                    tmp4<=tmpkernel[1];
                    tmp5<=tmppaddingimage[1][2];
                    tmp6<=tmpkernel[2];
                    tmp7<=tmppaddingimage[2][0];
                    tmp8<=tmpkernel[3];
                    tmp9<=tmppaddingimage[2][1];
                    tmp10<=tmpkernel[4];
                    tmp11<=tmppaddingimage[2][2];
                    tmp12<=tmpkernel[5];
                    tmp13<=tmppaddingimage[3][0];
                    tmp14<=tmpkernel[6];
                    tmp15<=tmppaddingimage[3][1];
                    tmp16<=tmpkernel[7];
                    tmp17<=tmppaddingimage[3][2];
                    tmp18<=tmpkernel[8];
                end
                5'd5:begin
                    tmp1<=tmppaddingimage[1][1];
                    tmp2<=tmpkernel[0];
                    tmp3<=tmppaddingimage[1][2];
                    tmp4<=tmpkernel[1];
                    tmp5<=tmppaddingimage[1][3];
                    tmp6<=tmpkernel[2];
                    tmp7<=tmppaddingimage[2][1];
                    tmp8<=tmpkernel[3];
                    tmp9<=tmppaddingimage[2][2];
                    tmp10<=tmpkernel[4];
                    tmp11<=tmppaddingimage[2][3];
                    tmp12<=tmpkernel[5];
                    tmp13<=tmppaddingimage[3][1];
                    tmp14<=tmpkernel[6];
                    tmp15<=tmppaddingimage[3][2];
                    tmp16<=tmpkernel[7];
                    tmp17<=tmppaddingimage[3][3];
                    tmp18<=tmpkernel[8];
                end
                5'd6:begin
                    tmp1<=tmppaddingimage[1][2];
                    tmp2<=tmpkernel[0];
                    tmp3<=tmppaddingimage[1][3];
                    tmp4<=tmpkernel[1];
                    tmp5<=tmppaddingimage[1][4];
                    tmp6<=tmpkernel[2];
                    tmp7<=tmppaddingimage[2][2];
                    tmp8<=tmpkernel[3];
                    tmp9<=tmppaddingimage[2][3];
                    tmp10<=tmpkernel[4];
                    tmp11<=tmppaddingimage[2][4];
                    tmp12<=tmpkernel[5];
                    tmp13<=tmppaddingimage[3][2];
                    tmp14<=tmpkernel[6];
                    tmp15<=tmppaddingimage[3][3];
                    tmp16<=tmpkernel[7];
                    tmp17<=tmppaddingimage[3][4];
                    tmp18<=tmpkernel[8];
                end
                5'd7:begin
                    tmp1<=tmppaddingimage[1][3];
                    tmp2<=tmpkernel[0];
                    tmp3<=tmppaddingimage[1][4];
                    tmp4<=tmpkernel[1];
                    tmp5<=tmppaddingimage[1][5];
                    tmp6<=tmpkernel[2];
                    tmp7<=tmppaddingimage[2][3];
                    tmp8<=tmpkernel[3];
                    tmp9<=tmppaddingimage[2][4];
                    tmp10<=tmpkernel[4];
                    tmp11<=tmppaddingimage[2][5];
                    tmp12<=tmpkernel[5];
                    tmp13<=tmppaddingimage[3][3];
                    tmp14<=tmpkernel[6];
                    tmp15<=tmppaddingimage[3][4];
                    tmp16<=tmpkernel[7];
                    tmp17<=tmppaddingimage[3][5];
                    tmp18<=tmpkernel[8];
                end
                5'd8:begin
                    tmp1<=tmppaddingimage[2][0];
                    tmp2<=tmpkernel[0];
                    tmp3<=tmppaddingimage[2][1];
                    tmp4<=tmpkernel[1];
                    tmp5<=tmppaddingimage[2][2];
                    tmp6<=tmpkernel[2];
                    tmp7<=tmppaddingimage[3][0];
                    tmp8<=tmpkernel[3];
                    tmp9<=tmppaddingimage[3][1];
                    tmp10<=tmpkernel[4];
                    tmp11<=tmppaddingimage[3][2];
                    tmp12<=tmpkernel[5];
                    tmp13<=tmppaddingimage[4][0];
                    tmp14<=tmpkernel[6];
                    tmp15<=tmppaddingimage[4][1];
                    tmp16<=tmpkernel[7];
                    tmp17<=tmppaddingimage[4][2];
                    tmp18<=tmpkernel[8];
                end
                5'd9:begin
                    tmp1<=tmppaddingimage[2][1];
                    tmp2<=tmpkernel[0];
                    tmp3<=tmppaddingimage[2][2];
                    tmp4<=tmpkernel[1];
                    tmp5<=tmppaddingimage[2][3];
                    tmp6<=tmpkernel[2];
                    tmp7<=tmppaddingimage[3][1];
                    tmp8<=tmpkernel[3];
                    tmp9<=tmppaddingimage[3][2];
                    tmp10<=tmpkernel[4];
                    tmp11<=tmppaddingimage[3][3];
                    tmp12<=tmpkernel[5];
                    tmp13<=tmppaddingimage[4][1];
                    tmp14<=tmpkernel[6];
                    tmp15<=tmppaddingimage[4][2];
                    tmp16<=tmpkernel[7];
                    tmp17<=tmppaddingimage[4][3];
                    tmp18<=tmpkernel[8];
                end
                5'd10:begin
                    tmp1<=tmppaddingimage[2][2];
                    tmp2<=tmpkernel[0];
                    tmp3<=tmppaddingimage[2][3];
                    tmp4<=tmpkernel[1];
                    tmp5<=tmppaddingimage[2][4];
                    tmp6<=tmpkernel[2];
                    tmp7<=tmppaddingimage[3][2];
                    tmp8<=tmpkernel[3];
                    tmp9<=tmppaddingimage[3][3];
                    tmp10<=tmpkernel[4];
                    tmp11<=tmppaddingimage[3][4];
                    tmp12<=tmpkernel[5];
                    tmp13<=tmppaddingimage[4][2];
                    tmp14<=tmpkernel[6];
                    tmp15<=tmppaddingimage[4][3];
                    tmp16<=tmpkernel[7];
                    tmp17<=tmppaddingimage[4][4];
                    tmp18<=tmpkernel[8];
                end
                5'd11:begin
                    tmp1<=tmppaddingimage[2][3];
                    tmp2<=tmpkernel[0];
                    tmp3<=tmppaddingimage[2][4];
                    tmp4<=tmpkernel[1];
                    tmp5<=tmppaddingimage[2][5];
                    tmp6<=tmpkernel[2];
                    tmp7<=tmppaddingimage[3][3];
                    tmp8<=tmpkernel[3];
                    tmp9<=tmppaddingimage[3][4];
                    tmp10<=tmpkernel[4];
                    tmp11<=tmppaddingimage[3][5];
                    tmp12<=tmpkernel[5];
                    tmp13<=tmppaddingimage[4][3];
                    tmp14<=tmpkernel[6];
                    tmp15<=tmppaddingimage[4][4];
                    tmp16<=tmpkernel[7];
                    tmp17<=tmppaddingimage[4][5];
                    tmp18<=tmpkernel[8];
                end
                5'd12:begin
                    tmp1<=tmppaddingimage[3][0];
                    tmp2<=tmpkernel[0];
                    tmp3<=tmppaddingimage[3][1];
                    tmp4<=tmpkernel[1];
                    tmp5<=tmppaddingimage[3][2];
                    tmp6<=tmpkernel[2];
                    tmp7<=tmppaddingimage[4][0];
                    tmp8<=tmpkernel[3];
                    tmp9<=tmppaddingimage[4][1];
                    tmp10<=tmpkernel[4];
                    tmp11<=tmppaddingimage[4][2];
                    tmp12<=tmpkernel[5];
                    tmp13<=tmppaddingimage[5][0];
                    tmp14<=tmpkernel[6];
                    tmp15<=tmppaddingimage[5][1];
                    tmp16<=tmpkernel[7];
                    tmp17<=tmppaddingimage[5][2];
                    tmp18<=tmpkernel[8];
                end
                5'd13:begin
                    tmp1<=tmppaddingimage[3][1];
                    tmp2<=tmpkernel[0];
                    tmp3<=tmppaddingimage[3][2];
                    tmp4<=tmpkernel[1];
                    tmp5<=tmppaddingimage[3][3];
                    tmp6<=tmpkernel[2];
                    tmp7<=tmppaddingimage[4][1];
                    tmp8<=tmpkernel[3];
                    tmp9<=tmppaddingimage[4][2];
                    tmp10<=tmpkernel[4];
                    tmp11<=tmppaddingimage[4][3];
                    tmp12<=tmpkernel[5];
                    tmp13<=tmppaddingimage[5][1];
                    tmp14<=tmpkernel[6];
                    tmp15<=tmppaddingimage[5][2];
                    tmp16<=tmpkernel[7];
                    tmp17<=tmppaddingimage[5][3];
                    tmp18<=tmpkernel[8];
                end
                5'd14:begin
                    tmp1<=tmppaddingimage[3][2];
                    tmp2<=tmpkernel[0];
                    tmp3<=tmppaddingimage[3][3];
                    tmp4<=tmpkernel[1];
                    tmp5<=tmppaddingimage[3][4];
                    tmp6<=tmpkernel[2];
                    tmp7<=tmppaddingimage[4][2];
                    tmp8<=tmpkernel[3];
                    tmp9<=tmppaddingimage[4][3];
                    tmp10<=tmpkernel[4];
                    tmp11<=tmppaddingimage[4][4];
                    tmp12<=tmpkernel[5];
                    tmp13<=tmppaddingimage[5][2];
                    tmp14<=tmpkernel[6];
                    tmp15<=tmppaddingimage[5][3];
                    tmp16<=tmpkernel[7];
                    tmp17<=tmppaddingimage[5][4];
                    tmp18<=tmpkernel[8];
                end
                5'd15:begin
                    tmp1<=tmppaddingimage[3][3];
                    tmp2<=tmpkernel[0];
                    tmp3<=tmppaddingimage[3][4];
                    tmp4<=tmpkernel[1];
                    tmp5<=tmppaddingimage[3][5];
                    tmp6<=tmpkernel[2];
                    tmp7<=tmppaddingimage[4][3];
                    tmp8<=tmpkernel[3];
                    tmp9<=tmppaddingimage[4][4];
                    tmp10<=tmpkernel[4];
                    tmp11<=tmppaddingimage[4][5];
                    tmp12<=tmpkernel[5];
                    tmp13<=tmppaddingimage[5][3];
                    tmp14<=tmpkernel[6];
                    tmp15<=tmppaddingimage[5][4];
                    tmp16<=tmpkernel[7];
                    tmp17<=tmppaddingimage[5][5];
                    tmp18<=tmpkernel[8];
                end
                default:begin
                    tmp1<=0;
                    tmp2<=0;
                    tmp3<=0;
                    tmp4<=0;
                    tmp5<=0;
                    tmp6<=0;
                    tmp7<=0;
                    tmp8<=0;
                    tmp9<=0;
                    tmp10<=0;
                    tmp11<=0;
                    tmp12<=0;
                    tmp13<=0;
                    tmp14<=0;
                    tmp15<=0;
                    tmp16<=0;
                    tmp17<=0;
                    tmp18<=0;
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
                    tmp7<=maxpool1[0][0];
                    tmp8<=weighttmp[1];
                    tmp9<=maxpool1[0][1];
                    tmp10<=weighttmp[3];
                    tmp11<=0;
                    tmp12<=0;
                end
                8'd119:begin
                    tmp1<=maxpool1[1][0];
                    tmp2<=weighttmp[0];
                    tmp3<=maxpool1[1][1];
                    tmp4<=weighttmp[2];
                    tmp5<=0;
                    tmp6<=0;
                    tmp7<=maxpool1[1][0];
                    tmp8<=weighttmp[1];
                    tmp9<=maxpool1[1][1];
                    tmp10<=weighttmp[3];
                    tmp11<=0;
                    tmp12<=0;
                end
                8'd124:begin
                    tmp1<=maxpool2[0][0];
                    tmp2<=weighttmp[0];
                    tmp3<=maxpool2[0][1];
                    tmp4<=weighttmp[2];
                    tmp5<=0;
                    tmp6<=0;
                    tmp7<=maxpool2[0][0];
                    tmp8<=weighttmp[1];
                    tmp9<=maxpool2[0][1];
                    tmp10<=weighttmp[3];
                    tmp11<=0;
                    tmp12<=0;
                end
                8'd125:begin
                    tmp1<=maxpool2[1][0];
                    tmp2<=weighttmp[0];
                    tmp3<=maxpool2[1][1];
                    tmp4<=weighttmp[2];
                    tmp5<=0;
                    tmp6<=0;
                    tmp7<=maxpool2[1][0];
                    tmp8<=weighttmp[1];
                    tmp9<=maxpool2[1][1];
                    tmp10<=weighttmp[3];
                    tmp11<=0;
                    tmp12<=0;
                end
                default:begin
                    tmp1<=0;
                    tmp2<=0;
                    tmp3<=0;
                    tmp4<=0;
                    tmp5<=0;
                    tmp6<=0;
                    tmp7<=0;
                    tmp8<=0;
                    tmp9<=0;
                    tmp10<=0;
                    tmp11<=0;
                    tmp12<=0;
                    tmp13<=0;
                    tmp14<=0;
                    tmp15<=0;
                    tmp16<=0;
                    tmp17<=0;
                    tmp18<=0;
                end
            endcase
        end
        
    end
end

DW_fp_dp3 #(inst_sig_width,inst_exp_width,inst_ieee_compliance,inst_arch_type) m1(.a(tmp1),.b(tmp2),.c(tmp3),.d(tmp4),.e(tmp5),.f(tmp6),.rnd(3'b0),.z(sum1));
DW_fp_dp3 #(inst_sig_width,inst_exp_width,inst_ieee_compliance,inst_arch_type) m2(.a(tmp7),.b(tmp8),.c(tmp9),.d(tmp10),.e(tmp11),.f(tmp12),.rnd(3'b0),.z(sum2));
DW_fp_dp3 #(inst_sig_width,inst_exp_width,inst_ieee_compliance,inst_arch_type) m3(.a(tmp13),.b(tmp14),.c(tmp15),.d(tmp16),.e(tmp17),.f(tmp18),.rnd(3'b0),.z(sum3));
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (integer i =0 ;i<4 ;i=i+1 ) begin
            for (integer j =0 ;j<4 ;j=j+1 ) begin
                futuremmap1_1[i][j]<=0;
            end
        end
    end
    else begin
        case (clkcnt)
            8'd19:futuremmap1_1[0][0]<=convtmp3;
            8'd20:futuremmap1_1[0][1]<=convtmp3;
            8'd21:futuremmap1_1[0][2]<=convtmp3;
            8'd22:futuremmap1_1[0][3]<=convtmp3;
            8'd23:futuremmap1_1[1][0]<=convtmp3;
            8'd24:futuremmap1_1[1][1]<=convtmp3; 
            8'd25:futuremmap1_1[1][2]<=convtmp3;
            8'd26:futuremmap1_1[1][3]<=convtmp3;
            8'd27:futuremmap1_1[2][0]<=convtmp3;
            8'd28:futuremmap1_1[2][1]<=convtmp3;
            8'd29:futuremmap1_1[2][2]<=convtmp3;
            8'd30:futuremmap1_1[2][3]<=convtmp3;
            8'd31:futuremmap1_1[3][0]<=convtmp3;
            8'd32:futuremmap1_1[3][1]<=convtmp3;
            8'd33:futuremmap1_1[3][2]<=convtmp3;
            8'd34:futuremmap1_1[3][3]<=convtmp3;
        endcase 
    end
end
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (integer i =0 ;i<4 ;i=i+1 ) begin
            for (integer j =0 ;j<4 ;j=j+1 ) begin
                futuremmap1_2[i][j]<=0;
            end
        end
    end
    else begin
        case (clkcnt)
            8'd36:futuremmap1_2[0][0]<=convtmp3;
            8'd37:futuremmap1_2[0][1]<=convtmp3;
            8'd38:futuremmap1_2[0][2]<=convtmp3;
            8'd39:futuremmap1_2[0][3]<=convtmp3;
            8'd40:futuremmap1_2[1][0]<=convtmp3;
            8'd41:futuremmap1_2[1][1]<=convtmp3; 
            8'd42:futuremmap1_2[1][2]<=convtmp3;
            8'd43:futuremmap1_2[1][3]<=convtmp3;
            8'd44:futuremmap1_2[2][0]<=convtmp3;
            8'd45:futuremmap1_2[2][1]<=convtmp3;
            8'd46:futuremmap1_2[2][2]<=convtmp3;
            8'd47:futuremmap1_2[2][3]<=convtmp3;
            8'd48:futuremmap1_2[3][0]<=convtmp3;
            8'd49:futuremmap1_2[3][1]<=convtmp3;
            8'd50:futuremmap1_2[3][2]<=convtmp3;
            8'd51:futuremmap1_2[3][3]<=convtmp3;
        endcase 
    end
end
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (integer i =0 ;i<4 ;i=i+1 ) begin
            for (integer j =0 ;j<4 ;j=j+1 ) begin
                futuremmap1_3[i][j]<=0;
            end
        end
    end
    else begin
        case (clkcnt)
            8'd53:futuremmap1_3[0][0]<=convtmp3;
            8'd54:futuremmap1_3[0][1]<=convtmp3;
            8'd55:futuremmap1_3[0][2]<=convtmp3;
            8'd56:futuremmap1_3[0][3]<=convtmp3;
            8'd57:futuremmap1_3[1][0]<=convtmp3;
            8'd58:futuremmap1_3[1][1]<=convtmp3; 
            8'd59:futuremmap1_3[1][2]<=convtmp3;
            8'd60:futuremmap1_3[1][3]<=convtmp3;
            8'd61:futuremmap1_3[2][0]<=convtmp3;
            8'd62:futuremmap1_3[2][1]<=convtmp3;
            8'd63:futuremmap1_3[2][2]<=convtmp3;
            8'd64:futuremmap1_3[2][3]<=convtmp3;
            8'd65:futuremmap1_3[3][0]<=convtmp3;
            8'd66:futuremmap1_3[3][1]<=convtmp3;
            8'd67:futuremmap1_3[3][2]<=convtmp3;
            8'd68:futuremmap1_3[3][3]<=convtmp3;
        endcase 
    end
end
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (integer i =0 ;i<4 ;i=i+1 ) begin
            for (integer j =0 ;j<4 ;j=j+1 ) begin
                futuremmap2_1[i][j]<=0;
            end
        end
    end
    else begin
        case (clkcnt)
            8'd70:futuremmap2_1[0][0]<=convtmp3;
            8'd71:futuremmap2_1[0][1]<=convtmp3;
            8'd72:futuremmap2_1[0][2]<=convtmp3;
            8'd73:futuremmap2_1[0][3]<=convtmp3;
            8'd74:futuremmap2_1[1][0]<=convtmp3;
            8'd75:futuremmap2_1[1][1]<=convtmp3; 
            8'd76:futuremmap2_1[1][2]<=convtmp3;
            8'd77:futuremmap2_1[1][3]<=convtmp3;
            8'd78:futuremmap2_1[2][0]<=convtmp3;
            8'd79:futuremmap2_1[2][1]<=convtmp3;
            8'd80:futuremmap2_1[2][2]<=convtmp3;
            8'd81:futuremmap2_1[2][3]<=convtmp3;
            8'd82:futuremmap2_1[3][0]<=convtmp3;
            8'd83:futuremmap2_1[3][1]<=convtmp3;
            8'd84:futuremmap2_1[3][2]<=convtmp3;
            8'd85:futuremmap2_1[3][3]<=convtmp3;
        endcase 
    end
end
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (integer i =0 ;i<4 ;i=i+1 ) begin
            for (integer j =0 ;j<4 ;j=j+1 ) begin
                futuremmap2_2[i][j]<=0;
            end
        end
    end
    else begin
        case (clkcnt)
            8'd87:futuremmap2_2[0][0]<=convtmp3;
            8'd88:futuremmap2_2[0][1]<=convtmp3;
            8'd89:futuremmap2_2[0][2]<=convtmp3;
            8'd90:futuremmap2_2[0][3]<=convtmp3;
            8'd91:futuremmap2_2[1][0]<=convtmp3;
            8'd92:futuremmap2_2[1][1]<=convtmp3; 
            8'd93:futuremmap2_2[1][2]<=convtmp3;
            8'd94:futuremmap2_2[1][3]<=convtmp3;
            8'd95:futuremmap2_2[2][0]<=convtmp3;
            8'd96:futuremmap2_2[2][1]<=convtmp3;
            8'd97:futuremmap2_2[2][2]<=convtmp3;
            8'd98:futuremmap2_2[2][3]<=convtmp3;
            8'd99:futuremmap2_2[3][0]<=convtmp3;
            8'd100:futuremmap2_2[3][1]<=convtmp3;
            8'd101:futuremmap2_2[3][2]<=convtmp3;
            8'd102:futuremmap2_2[3][3]<=convtmp3;
        endcase 
    end
end
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (integer i =0 ;i<4 ;i=i+1 ) begin
            for (integer j =0 ;j<4 ;j=j+1 ) begin
                futuremmap2_3[i][j]<=0;
            end
        end
    end
    else begin
        case (clkcnt)
            8'd104:futuremmap2_3[0][0]<=convtmp3;
            8'd105:futuremmap2_3[0][1]<=convtmp3;
            8'd106:futuremmap2_3[0][2]<=convtmp3;
            8'd107:futuremmap2_3[0][3]<=convtmp3;
            8'd108:futuremmap2_3[1][0]<=convtmp3;
            8'd109:futuremmap2_3[1][1]<=convtmp3; 
            8'd110:futuremmap2_3[1][2]<=convtmp3;
            8'd111:futuremmap2_3[1][3]<=convtmp3;
            8'd112:futuremmap2_3[2][0]<=convtmp3;
            8'd113:futuremmap2_3[2][1]<=convtmp3;
            8'd114:futuremmap2_3[2][2]<=convtmp3;
            8'd115:futuremmap2_3[2][3]<=convtmp3;
            8'd116:futuremmap2_3[3][0]<=convtmp3;
            8'd117:futuremmap2_3[3][1]<=convtmp3;
            8'd118:futuremmap2_3[3][2]<=convtmp3;
            8'd119:futuremmap2_3[3][3]<=convtmp3;
        endcase 
    end
end
always @(posedge clk or negedge rst_n) begin
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
            8'd142:begin
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
            8'd144:begin
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
            8'd146:begin
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
            8'd148:begin
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
            8'd149:begin
                addforthree1<=vector1[0];
                addforthree2<={!vector2[0][31],vector2[0][30:0]};
                addforthree3<=0;
            end
            8'd150:begin
                addforthree1<=vector1[2];
                addforthree2<={!vector2[2][31],vector2[2][30:0]};
                addforthree3<=0;
            end
            8'd151:begin
                addforthree1<=vector1[3];
                addforthree2<={!vector2[3][31],vector2[3][30:0]};
                addforthree3<=0;
            end
            8'd153:begin
                addforthree1<=distancetmp3;
                addforthree2<=distancetmp4;
                addforthree3<=convtmp;
            end
            default:begin
                addforthree1<=0;
                addforthree2<=0;
                addforthree3<=0;
            end
        endcase
        end
    end
end
always @(posedge clk or negedge rst_n) begin
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
            8'd130:begin
                addthree1<=normmax2;
                addthree2<=normmin2;
                addthree3<=0;
            end
            8'd132:begin
                addthree1<=fully2[0];
                addthree2<=normmin2;
                addthree3<=0;
            end
            8'd133:begin
                addthree1<=fully2[1];
                addthree2<=normmin2;
                addthree3<=0;
            end
            8'd134:begin
                addthree1<=fully2[2];
                addthree2<=normmin2;
                addthree3<=0;
            end
            8'd135:begin
                addthree1<=fully2[3];
                addthree2<=normmin2;
                addthree3<=0;
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
            8'd142:begin
                addthree1<=exp2_1pos;
                addthree2<={!exp2_1neg[31],exp2_1neg[30:0]};
                addthree3<=0;
            end
            8'd144:begin
                addthree1<=exp2_2pos;
                addthree2<={!exp2_2neg[31],exp2_2neg[30:0]};
                addthree3<=0;
            end
            8'd146:begin
                addthree1<=exp2_3pos;
                addthree2<={!exp2_3neg[31],exp2_3neg[30:0]};
                addthree3<=0;
            end
            8'd148:begin
                addthree1<=exp2_4pos;
                addthree2<={!exp2_4neg[31],exp2_4neg[30:0]};
                addthree3<=0;
            end
            8'd149:begin
                addthree1<=vector1[1];
                addthree2<={!vector2[1][31],vector2[1][30:0]};
                addthree3<=0;
            end
            8'd152:begin
                addthree1<=distancetmp1;
                addthree2<=distancetmp2;
                addthree3<=0;
            end
            default:begin
                addthree1<=0;
                addthree2<=0;
                addthree3<=0;
            end
        endcase
    end
end
DW_fp_sum3 #(inst_sig_width,inst_exp_width,inst_ieee_compliance,inst_arch_type) b1(.a(addforthree1),.b(addforthree2),.c(addforthree3),.rnd(3'b0),.z(convtmp3));
DW_fp_sum3 #(inst_sig_width,inst_exp_width,inst_ieee_compliance,inst_arch_type) b2(.a(addthree1),.b(addthree2),.c(addthree3),.rnd(3'b0),.z(convtmp));
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (integer i =0 ;i<4 ;i=i+1 ) begin
            for (integer j =0 ;j<4 ;j=j+1 ) begin
                futuremmap1[i][j]<=0;
            end
        end
    end
    else begin
        case (clkcnt)
            8'd55:futuremmap1[0][0]<=convtmp;
            8'd56:futuremmap1[0][1]<=convtmp;
            8'd57:futuremmap1[0][2]<=convtmp;
            8'd58:futuremmap1[0][3]<=convtmp;
            8'd59:futuremmap1[1][0]<=convtmp;
            8'd60:futuremmap1[1][1]<=convtmp;
            8'd61:futuremmap1[1][2]<=convtmp;
            8'd62:futuremmap1[1][3]<=convtmp;
            8'd63:futuremmap1[2][0]<=convtmp;
            8'd64:futuremmap1[2][1]<=convtmp;
            8'd65:futuremmap1[2][2]<=convtmp;
            8'd66:futuremmap1[2][3]<=convtmp;
            8'd67:futuremmap1[3][0]<=convtmp;
            8'd68:futuremmap1[3][1]<=convtmp;
            8'd69:futuremmap1[3][2]<=convtmp;
            8'd70:futuremmap1[3][3]<=convtmp; 
        endcase
    end
end
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (integer i =0 ;i<4 ;i=i+1 ) begin
            for (integer j =0 ;j<4 ;j=j+1 ) begin
                futuremmap2[i][j]<=0;
            end
        end
    end
    else begin
        case (clkcnt)
            8'd106:futuremmap2[0][0]<=convtmp;
            8'd107:futuremmap2[0][1]<=convtmp;
            8'd108:futuremmap2[0][2]<=convtmp;
            8'd109:futuremmap2[0][3]<=convtmp;
            8'd110:futuremmap2[1][0]<=convtmp;
            8'd111:futuremmap2[1][1]<=convtmp;
            8'd112:futuremmap2[1][2]<=convtmp;
            8'd113:futuremmap2[1][3]<=convtmp;
            8'd114:futuremmap2[2][0]<=convtmp;
            8'd115:futuremmap2[2][1]<=convtmp;
            8'd116:futuremmap2[2][2]<=convtmp;
            8'd117:futuremmap2[2][3]<=convtmp;
            8'd118:futuremmap2[3][0]<=convtmp;
            8'd119:futuremmap2[3][1]<=convtmp;
            8'd120:futuremmap2[3][2]<=convtmp;
            8'd121:futuremmap2[3][3]<=convtmp;
        endcase
    end
end
//Maxpooling
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        tmpcmpa<=0;
        tmpcmpb<=0;
    end
    else begin
        case (clkcnt)
            8'd61:begin
                tmpcmpa<=futuremmap1[0][0];
                tmpcmpb<=futuremmap1[0][1];
            end 
            8'd62:begin
                tmpcmpa<=max;
                tmpcmpb<=futuremmap1[1][0];
            end
            8'd63:begin
                tmpcmpa<=max;
                tmpcmpb<=futuremmap1[1][1];
            end
            8'd64:begin
                tmpcmpa<=futuremmap1[0][2];
                tmpcmpb<=futuremmap1[0][3];
            end 
            8'd65:begin
                tmpcmpa<=max;
                tmpcmpb<=futuremmap1[1][2];
            end
            8'd66:begin
                tmpcmpa<=max;
                tmpcmpb<=futuremmap1[1][3];
            end
            8'd67:begin
                tmpcmpa<=futuremmap1[2][0];
                tmpcmpb<=futuremmap1[2][1];
            end 
            8'd68:begin
                tmpcmpa<=max;
                tmpcmpb<=futuremmap1[3][0];
            end
            8'd69:begin
                tmpcmpa<=max;
                tmpcmpb<=futuremmap1[3][1];
            end
            8'd70:begin
                tmpcmpa<=futuremmap1[2][2];
                tmpcmpb<=futuremmap1[2][3];
            end 
            8'd71:begin
                tmpcmpa<=max;
                tmpcmpb<=futuremmap1[3][2];
            end
            8'd72:begin
                tmpcmpa<=max;
                tmpcmpb<=futuremmap1[3][3];
            end
            8'd112:begin
                tmpcmpa<=futuremmap2[0][0];
                tmpcmpb<=futuremmap2[0][1];
            end 
            8'd113:begin
                tmpcmpa<=max;
                tmpcmpb<=futuremmap2[1][0];
            end
            8'd114:begin
                tmpcmpa<=max;
                tmpcmpb<=futuremmap2[1][1];
            end
            8'd115:begin
                tmpcmpa<=futuremmap2[0][2];
                tmpcmpb<=futuremmap2[0][3];
            end 
            8'd116:begin
                tmpcmpa<=max;
                tmpcmpb<=futuremmap2[1][2];
            end
            8'd117:begin
                tmpcmpa<=max;
                tmpcmpb<=futuremmap2[1][3];
            end
            8'd118:begin
                tmpcmpa<=futuremmap2[2][0];
                tmpcmpb<=futuremmap2[2][1];
            end 
            8'd119:begin
                tmpcmpa<=max;
                tmpcmpb<=futuremmap2[3][0];
            end
            8'd120:begin
                tmpcmpa<=max;
                tmpcmpb<=futuremmap2[3][1];
            end
            8'd121:begin
                tmpcmpa<=futuremmap2[2][2];
                tmpcmpb<=futuremmap2[2][3];
            end 
            8'd122:begin
                tmpcmpa<=max;
                tmpcmpb<=futuremmap2[3][2];
            end
            8'd123:begin
                tmpcmpa<=max;
                tmpcmpb<=futuremmap2[3][3];
            end
            8'd126:begin
                tmpcmpa<=fully2[0];
                tmpcmpb<=fully2[1];
            end
            8'd127:begin
                tmpcmpa<=max;
                tmpcmpb<=fully2[2];
            end
            8'd128:begin
                tmpcmpa<=max;
                tmpcmpb<=fully2[3];
            end
            default:begin
                tmpcmpa<=0;
                tmpcmpb<=0;
            end

        endcase
    end
end
always @(posedge clk or negedge rst_n) begin
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
            8'd126:begin
                tmpcmp1<=fully2[0];
                tmpcmp2<=fully2[1];
            end
            8'd127:begin
                tmpcmp1<=min2;
                tmpcmp2<=fully2[2];
            end
            8'd128:begin
                tmpcmp1<=min2;
                tmpcmp2<=fully2[3];
            end
            default:begin
                tmpcmp1<=0;
                tmpcmp2<=0;
            end
        endcase
    end
end
DW_fp_cmp cmp1(.a(tmpcmpa),.b(tmpcmpb),.zctr(1'b1),.z0(max),.z1(min));
DW_fp_cmp cmp2(.a(tmpcmp1),.b(tmpcmp2),.zctr(1'b1),.z0(max2),.z1(min2));
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (integer i =0 ;i<2 ;i=i+1 ) begin
            for (integer j =0 ;j<2 ;j=j+1 ) begin
                maxpool1[i][j]<=0;
                maxpool2[i][j]<=0;
            end
        end
    end
    else begin
        case (clkcnt)
            8'd64:maxpool1[0][0]<=max;
            8'd67:maxpool1[0][1]<=max;
            8'd70:maxpool1[1][0]<=max;
            8'd73:maxpool1[1][1]<=max; 
            8'd115:maxpool2[0][0]<=max;
            8'd118:maxpool2[0][1]<=max;
            8'd121:maxpool2[1][0]<=max;
            8'd124:maxpool2[1][1]<=max;
        endcase
    end
end
//Fully connected
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (integer i =0 ;i<4 ;i=i+1 ) begin
            fully1[i]<=0;
            fully2[i]<=0;
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
            8'd125:begin
                fully2[0]<=sum1;
                fully2[1]<=sum2;
            end
            8'd126:begin
                fully2[2]<=sum1;
                fully2[3]<=sum2; 
            end
        endcase
    end
end
//Min-Max Normalization and Activation Function
always @(posedge clk or negedge rst_n) begin
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
            8'd129:begin
                normmax2<=max;
                normmin2<={!min2[31],min2[30:0]};
            end//改signed bit用加法
        endcase
    end
end
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        xmaxsubxmin1<=0;
        xmaxsubxmin2<=0;
    end
    else begin
        case (clkcnt)
            8'd128:xmaxsubxmin1<=convtmp3; 
            8'd131:xmaxsubxmin2<=convtmp;
        endcase
    end
end
always @(posedge clk or negedge rst_n) begin
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
            8'd133:begin
                divtmp1<=convtmp;
                divtmp2<=xmaxsubxmin2;
            end
            8'd134:begin
                divtmp1<=convtmp;
                divtmp2<=xmaxsubxmin2;
            end
            8'd135:begin
                divtmp1<=convtmp;
                divtmp2<=xmaxsubxmin2;
            end
            8'd136:begin
                divtmp1<=convtmp;
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
            8'd143:begin
                if(optreg[1]) divtmp1<=convtmp;
                else divtmp1<=one;
                divtmp2<=convtmp3;
            end
            8'd145:begin
                if(optreg[1]) divtmp1<=convtmp;
                else divtmp1<=one;
                divtmp2<=convtmp3;
            end
            8'd147:begin
                if(optreg[1]) divtmp1<=convtmp;
                else divtmp1<=one;
                divtmp2<=convtmp3;
            end
            8'd149:begin
                if(optreg[1]) divtmp1<=convtmp;
                else divtmp1<=one;
                divtmp2<=convtmp3;
            end
            default:begin
                divtmp1<=0;
                divtmp2<=0;
            end
        endcase
    end
end
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (integer i=0 ;i<4 ;i=i+1 ) begin
            norm1[i]<=0;
            norm2[i]<=0;
        end
    end
    else begin
        case (clkcnt)
            8'd130:norm1[0]<=divanswer;
            8'd131:norm1[1]<=divanswer;
            8'd132:norm1[2]<=divanswer;
            8'd133:norm1[3]<=divanswer;
            8'd134:norm2[0]<=divanswer;
            8'd135:norm2[1]<=divanswer;
            8'd136:norm2[2]<=divanswer;
            8'd137:norm2[3]<=divanswer;
        endcase
    end
end
DW_fp_div div1(.a(divtmp1),.b(divtmp2),.rnd(3'b0),.z(divanswer));
always @(posedge clk or negedge rst_n) begin
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
            8'd139:exptmp<=norm2[0];
            8'd140:exptmp<={!norm2[0][31],norm2[0][30:0]};
            8'd141:exptmp<=norm2[1];
            8'd142:exptmp<={!norm2[1][31],norm2[1][30:0]};
            8'd143:exptmp<=norm2[2];
            8'd144:exptmp<={!norm2[2][31],norm2[2][30:0]};
            8'd145:exptmp<=norm2[3];
            8'd146:exptmp<={!norm2[3][31],norm2[3][30:0]};
            default:exptmp<=0;
        endcase
    end
end
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        exp1_1pos<=0;
        exp1_1neg<=0;
        exp1_2pos<=0;
        exp1_2neg<=0;
        exp1_3pos<=0;
        exp1_3neg<=0;
        exp1_4pos<=0;
        exp1_4neg<=0;
        exp2_1pos<=0;
        exp2_1neg<=0;
        exp2_2pos<=0;
        exp2_2neg<=0;
        exp2_3pos<=0;
        exp2_3neg<=0;
        exp2_4pos<=0;
        exp2_4neg<=0;
    end
    else begin
        case (clkcnt)
            8'd132:exp1_1pos<=expout; 
            8'd133:exp1_1neg<=expout;
            8'd134:exp1_2pos<=expout;
            8'd135:exp1_2neg<=expout;
            8'd136:exp1_3pos<=expout;
            8'd137:exp1_3neg<=expout;
            8'd138:exp1_4pos<=expout;
            8'd139:exp1_4neg<=expout;
            8'd140:exp2_1pos<=expout; 
            8'd141:exp2_1neg<=expout;
            8'd142:exp2_2pos<=expout;
            8'd143:exp2_2neg<=expout;
            8'd144:exp2_3pos<=expout;
            8'd145:exp2_3neg<=expout;
            8'd146:exp2_4pos<=expout;
            8'd147:exp2_4neg<=expout;
        endcase
    end
end
always @(posedge clk or negedge rst_n) begin
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
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (integer i =0 ;i<4 ;i=i+1 ) begin
            vector1[i]<=0;
            vector2[i]<=0;
        end
    end
    else begin
        case (clkcnt)
            8'd140:vector1[0]<=divanswer; 
            8'd141:vector1[1]<=divanswer;
            8'd142:vector1[2]<=divanswer;
            8'd143:vector1[3]<=divanswer;
            8'd144:vector2[0]<=divanswer; 
            8'd146:vector2[1]<=divanswer;
            8'd148:vector2[2]<=divanswer;
            8'd150:vector2[3]<=divanswer;
        endcase
    end
end
DW_fp_exp #(inst_sig_width,inst_exp_width,1'b1) exp1(.a(exptmp),.z(expout));
//L1 distance
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        distancetmp1<=0;
        distancetmp2<=0;
        distancetmp3<=0;
        distancetmp4<=0;
    end
    else begin
        case (clkcnt)
            8'd150:begin
                distancetmp1<={1'b0,convtmp3[30:0]};
                distancetmp2<={1'b0,convtmp[30:0]};
            end
            8'd151:distancetmp3<={1'b0,convtmp3[30:0]};
            8'd152:distancetmp4<={1'b0,convtmp3[30:0]};
        endcase
    end
end

//Opt Input
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) optreg<=0;
    else begin
        if (in_valid&&clkcnt==0) begin
            optreg<=Opt;
        end
    end
end
//Image input
always @(posedge clk or negedge rst_n) begin
    if (!rst_n)begin
        for (integer i =0;i<96 ;i=i+1 ) begin
            image[i]<=0;   
        end
    end
    else begin
        if (in_valid&&clkcnt<=96) begin
            image[clkcnt]<=Img;
        end
    end
end
//Kernel Imput
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (integer i = 0; i < 27; i = i + 1) begin
            kerneltmp[i]<=0;
        end
    end
    else begin
        if (in_valid&&clkcnt<=27) begin
            kerneltmp[clkcnt]<=Kernel;
        end
    end
end
//Weight Input
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (integer i = 0; i < 4; i = i + 1) begin
            weighttmp[i]<=0;
        end
    end
    else begin
        if (in_valid&&clkcnt<=4) begin
            weighttmp[clkcnt]<=Weight;
        end
    end
end

//out_valid
always @(*) begin
    if (clkcnt==155) begin
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
        if (clkcnt==154) begin
            out<=convtmp3;
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
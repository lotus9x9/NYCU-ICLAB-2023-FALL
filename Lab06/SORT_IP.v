//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//    (C) Copyright System Integration and Silicon Implementation Laboratory
//    All Right Reserved
//		Date		: 2023/10
//		Version		: v1.0
//   	File Name   : SORT_IP.v
//   	Module Name : SORT_IP
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################
module SORT_IP #(parameter IP_WIDTH = 8) (
    // Input signals
    IN_character, IN_weight,
    // Output signals
    OUT_character
);

// ===============================================================
// Input & Output
// ===============================================================
input [IP_WIDTH*4-1:0]  IN_character;
input [IP_WIDTH*5-1:0]  IN_weight;

output  [IP_WIDTH*4-1:0] OUT_character;

// ===============================================================
// Design
// ===============================================================
wire [4:0]a,b,c,d,e,f,g,h;
wire [3:0]index[1:38];
wire [4:0]big1,big2,big3,big4,big5,big6,big7,big8,big9,big10,big11,big12,big13,big14,big15,big16,big17,big18,big19;
wire [4:0]small1,small2,small3,small4,small5,small6,small7,small8,small9,small10,small11,small12,small13,small14,small15,small16,small17,small18,small19;
generate
    case (IP_WIDTH)
        3:begin
            assign a=IN_weight[14:10];
            assign b=IN_weight[9:5];
            assign c=IN_weight[4:0];
            cmp c1 (.a(a),.b(c),.aidx(IN_character[11:8]),.bidx(IN_character[3:0]),.out1(big1),.out2(small1),.out1idx(index[1]),.out2idx(index[2]));
            cmp c2 (.a(big1),.b(b),.aidx(index[1]),.bidx(IN_character[7:4]),.out1(big2),.out2(small2),.out1idx(index[3]),.out2idx(index[4]));
            cmp c3 (.a(small2),.b(small1),.aidx(index[4]),.bidx(index[2]),.out1(big3),.out2(small3),.out1idx(index[5]),.out2idx(index[6]));
            assign OUT_character={index[3],index[5],index[6]};
        end
        4:begin
            assign a=IN_weight[19:15];
            assign b=IN_weight[14:10];
            assign c=IN_weight[9:5];
            assign d=IN_weight[4:0];
            cmp c1 (.a(a),.b(c),.aidx(IN_character[15:12]),.bidx(IN_character[7:4]),.out1(big1),.out2(small1),.out1idx(index[1]),.out2idx(index[2]));
            cmp c2 (.a(b),.b(d),.aidx(IN_character[11:8]),.bidx(IN_character[3:0]),.out1(big2),.out2(small2),.out1idx(index[3]),.out2idx(index[4]));
            cmp c3 (.a(big1),.b(big2),.aidx(index[1]),.bidx(index[3]),.out1(big3),.out2(small3),.out1idx(index[5]),.out2idx(index[6]));
            cmp c4 (.a(small1),.b(small2),.aidx(index[2]),.bidx(index[4]),.out1(big4),.out2(small4),.out1idx(index[7]),.out2idx(index[8]));
            cmp c5 (.a(small3),.b(big4),.aidx(index[6]),.bidx(index[7]),.out1(big5),.out2(small5),.out1idx(index[9]),.out2idx(index[10]));
            assign OUT_character={index[5],index[9],index[10],index[8]};
        end
        5:begin
            assign a=IN_weight[24:20];
            assign b=IN_weight[19:15];
            assign c=IN_weight[14:10];
            assign d=IN_weight[9:5];
            assign e=IN_weight[4:0];
            cmp c1 (.a(a),.b(d),.aidx(IN_character[19:16]),.bidx(IN_character[7:4]),.out1(big1),.out2(small1),.out1idx(index[1]),.out2idx(index[2]));
            cmp c2 (.a(b),.b(e),.aidx(IN_character[15:12]),.bidx(IN_character[3:0]),.out1(big2),.out2(small2),.out1idx(index[3]),.out2idx(index[4]));
            cmp c3 (.a(big1),.b(c),.aidx(index[1]),.bidx(IN_character[11:8]),.out1(big3),.out2(small3),.out1idx(index[5]),.out2idx(index[6]));
            cmp c4 (.a(big2),.b(small1),.aidx(index[3]),.bidx(index[2]),.out1(big4),.out2(small4),.out1idx(index[7]),.out2idx(index[8]));
            cmp c5 (.a(big3),.b(big4),.aidx(index[5]),.bidx(index[7]),.out1(big5),.out2(small5),.out1idx(index[9]),.out2idx(index[10]));
            cmp c6 (.a(small3),.b(small2),.aidx(index[6]),.bidx(index[4]),.out1(big6),.out2(small6),.out1idx(index[11]),.out2idx(index[12]));
            cmp c7 (.a(small5),.b(big6),.aidx(index[10]),.bidx(index[11]),.out1(big7),.out2(small7),.out1idx(index[13]),.out2idx(index[14]));
            cmp c8 (.a(small4),.b(small6),.aidx(index[8]),.bidx(index[12]),.out1(big8),.out2(small8),.out1idx(index[15]),.out2idx(index[16]));
            cmp c9 (.a(small7),.b(big8),.aidx(index[14]),.bidx(index[15]),.out1(big9),.out2(small9),.out1idx(index[17]),.out2idx(index[18]));
            assign OUT_character={index[9],index[13],index[17],index[18],index[16]};
        end
        6:begin
            assign a=IN_weight[29:25];
            assign b=IN_weight[24:20];
            assign c=IN_weight[19:15];
            assign d=IN_weight[14:10];
            assign e=IN_weight[9:5];
            assign f=IN_weight[4:0];
            cmp c1 (.a(b),.b(d),.aidx(IN_character[19:16]),.bidx(IN_character[11:8]),.out1(big1),.out2(small1),.out1idx(index[1]),.out2idx(index[2]));
            cmp c2 (.a(a),.b(f),.aidx(IN_character[23:20]),.bidx(IN_character[3:0]),.out1(big2),.out2(small2),.out1idx(index[3]),.out2idx(index[4]));
            cmp c3 (.a(c),.b(e),.aidx(IN_character[15:12]),.bidx(IN_character[7:4]),.out1(big3),.out2(small3),.out1idx(index[5]),.out2idx(index[6]));
            cmp c4 (.a(big1),.b(big3),.aidx(index[1]),.bidx(index[5]),.out1(big4),.out2(small4),.out1idx(index[7]),.out2idx(index[8]));
            cmp c5 (.a(small1),.b(small3),.aidx(index[2]),.bidx(index[6]),.out1(big5),.out2(small5),.out1idx(index[9]),.out2idx(index[10]));
            cmp c6 (.a(big2),.b(big5),.aidx(index[3]),.bidx(index[9]),.out1(big6),.out2(small6),.out1idx(index[11]),.out2idx(index[12]));
            cmp c7 (.a(small4),.b(small2),.aidx(index[8]),.bidx(index[4]),.out1(big7),.out2(small7),.out1idx(index[13]),.out2idx(index[14]));
            cmp c8 (.a(big6),.b(big4),.aidx(index[11]),.bidx(index[7]),.out1(big8),.out2(small8),.out1idx(index[15]),.out2idx(index[16]));
            cmp c9 (.a(big7),.b(small6),.aidx(index[13]),.bidx(index[12]),.out1(big9),.out2(small9),.out1idx(index[17]),.out2idx(index[18]));
            cmp c10 (.a(small5),.b(small7),.aidx(index[10]),.bidx(index[14]),.out1(big10),.out2(small10),.out1idx(index[19]),.out2idx(index[20]));
            cmp c11 (.a(small8),.b(big9),.aidx(index[16]),.bidx(index[17]),.out1(big11),.out2(small11),.out1idx(index[21]),.out2idx(index[22]));
            cmp c12 (.a(small9),.b(big10),.aidx(index[18]),.bidx(index[19]),.out1(big12),.out2(small12),.out1idx(index[23]),.out2idx(index[24]));
            assign OUT_character={index[15],index[21],index[22],index[23],index[24],index[20]};
        end
        7:begin
            assign a=IN_weight[34:30];
            assign b=IN_weight[29:25];
            assign c=IN_weight[24:20];
            assign d=IN_weight[19:15];
            assign e=IN_weight[14:10];
            assign f=IN_weight[9:5];
            assign g=IN_weight[4:0];
            cmp c1 (.a(a),.b(g),.aidx(IN_character[27:24]),.bidx(IN_character[3:0]),.out1(big1),.out2(small1),.out1idx(index[1]),.out2idx(index[2]));
            cmp c2 (.a(c),.b(d),.aidx(IN_character[19:16]),.bidx(IN_character[15:12]),.out1(big2),.out2(small2),.out1idx(index[3]),.out2idx(index[4]));
            cmp c3 (.a(e),.b(f),.aidx(IN_character[11:8]),.bidx(IN_character[7:4]),.out1(big3),.out2(small3),.out1idx(index[5]),.out2idx(index[6]));
            cmp c4 (.a(b),.b(big3),.aidx(IN_character[23:20]),.bidx(index[5]),.out1(big4),.out2(small4),.out1idx(index[7]),.out2idx(index[8]));
            cmp c5 (.a(big1),.b(big2),.aidx(index[1]),.bidx(index[3]),.out1(big5),.out2(small5),.out1idx(index[9]),.out2idx(index[10]));
            cmp c6 (.a(small2),.b(small1),.aidx(index[4]),.bidx(index[2]),.out1(big6),.out2(small6),.out1idx(index[11]),.out2idx(index[12]));
            cmp c7 (.a(big5),.b(big4),.aidx(index[9]),.bidx(index[7]),.out1(big7),.out2(small7),.out1idx(index[13]),.out2idx(index[14]));
            cmp c8 (.a(big6),.b(small4),.aidx(index[11]),.bidx(index[8]),.out1(big8),.out2(small8),.out1idx(index[15]),.out2idx(index[16]));
            cmp c9 (.a(small5),.b(small3),.aidx(index[10]),.bidx(index[6]),.out1(big9),.out2(small9),.out1idx(index[17]),.out2idx(index[18]));
            cmp c10 (.a(small7),.b(big9),.aidx(index[14]),.bidx(index[17]),.out1(big10),.out2(small10),.out1idx(index[19]),.out2idx(index[20]));
            cmp c11 (.a(small8),.b(small6),.aidx(index[16]),.bidx(index[12]),.out1(big11),.out2(small11),.out1idx(index[21]),.out2idx(index[22]));
            cmp c12 (.a(small10),.b(big8),.aidx(index[20]),.bidx(index[15]),.out1(big12),.out2(small12),.out1idx(index[23]),.out2idx(index[24]));
            cmp c13 (.a(big11),.b(small9),.aidx(index[21]),.bidx(index[18]),.out1(big13),.out2(small13),.out1idx(index[25]),.out2idx(index[26]));
            cmp c14 (.a(big10),.b(big12),.aidx(index[19]),.bidx(index[23]),.out1(big14),.out2(small14),.out1idx(index[27]),.out2idx(index[28]));
            cmp c15 (.a(small12),.b(big13),.aidx(index[24]),.bidx(index[25]),.out1(big15),.out2(small15),.out1idx(index[29]),.out2idx(index[30]));
            cmp c16 (.a(small13),.b(small11),.aidx(index[26]),.bidx(index[22]),.out1(big16),.out2(small16),.out1idx(index[31]),.out2idx(index[32]));
            assign OUT_character={index[13],index[27],index[28],index[29],index[30],index[31],index[32]};
        end
        8:begin
            assign a=IN_weight[39:35];
            assign b=IN_weight[34:30];
            assign c=IN_weight[29:25];
            assign d=IN_weight[24:20];
            assign e=IN_weight[19:15];
            assign f=IN_weight[14:10];
            assign g=IN_weight[9:5];
            assign h=IN_weight[4:0];
            cmp c1 (.a(b),.b(d),.aidx(IN_character[27:24]),.bidx(IN_character[19:16]),.out1(big1),.out2(small1),.out1idx(index[1]),.out2idx(index[2]));
            cmp c2 (.a(e),.b(g),.aidx(IN_character[15:12]),.bidx(IN_character[7:4]),.out1(big2),.out2(small2),.out1idx(index[3]),.out2idx(index[4]));
            cmp c3 (.a(a),.b(c),.aidx(IN_character[31:28]),.bidx(IN_character[23:20]),.out1(big3),.out2(small3),.out1idx(index[5]),.out2idx(index[6]));
            cmp c4 (.a(f),.b(h),.aidx(IN_character[11:8]),.bidx(IN_character[3:0]),.out1(big4),.out2(small4),.out1idx(index[7]),.out2idx(index[8]));
            cmp c5 (.a(big3),.b(big2),.aidx(index[5]),.bidx(index[3]),.out1(big5),.out2(small5),.out1idx(index[9]),.out2idx(index[10]));
            cmp c6 (.a(big1),.b(big4),.aidx(index[1]),.bidx(index[7]),.out1(big6),.out2(small6),.out1idx(index[11]),.out2idx(index[12]));
            cmp c7 (.a(small3),.b(small2),.aidx(index[6]),.bidx(index[4]),.out1(big7),.out2(small7),.out1idx(index[13]),.out2idx(index[14]));
            cmp c8 (.a(small1),.b(small4),.aidx(index[2]),.bidx(index[8]),.out1(big8),.out2(small8),.out1idx(index[15]),.out2idx(index[16]));
            cmp c9 (.a(big5),.b(big6),.aidx(index[9]),.bidx(index[11]),.out1(big9),.out2(small9),.out1idx(index[17]),.out2idx(index[18]));
            cmp c10 (.a(big7),.b(big8),.aidx(index[13]),.bidx(index[15]),.out1(big10),.out2(small10),.out1idx(index[19]),.out2idx(index[20]));
            cmp c11 (.a(small5),.b(small6),.aidx(index[10]),.bidx(index[12]),.out1(big11),.out2(small11),.out1idx(index[21]),.out2idx(index[22]));
            cmp c12 (.a(small7),.b(small8),.aidx(index[14]),.bidx(index[16]),.out1(big12),.out2(small12),.out1idx(index[23]),.out2idx(index[24]));
            cmp c13 (.a(big10),.b(big11),.aidx(index[19]),.bidx(index[21]),.out1(big13),.out2(small13),.out1idx(index[25]),.out2idx(index[26]));
            cmp c14 (.a(small10),.b(small11),.aidx(index[20]),.bidx(index[22]),.out1(big14),.out2(small14),.out1idx(index[27]),.out2idx(index[28]));
            cmp c15 (.a(small9),.b(small13),.aidx(index[18]),.bidx(index[26]),.out1(big15),.out2(small15),.out1idx(index[29]),.out2idx(index[30]));
            cmp c16 (.a(big14),.b(big12),.aidx(index[27]),.bidx(index[23]),.out1(big16),.out2(small16),.out1idx(index[31]),.out2idx(index[32]));
            cmp c17 (.a(big15),.b(big13),.aidx(index[29]),.bidx(index[25]),.out1(big17),.out2(small17),.out1idx(index[33]),.out2idx(index[34]));
            cmp c18 (.a(big16),.b(small15),.aidx(index[31]),.bidx(index[30]),.out1(big18),.out2(small18),.out1idx(index[35]),.out2idx(index[36]));
            cmp c19 (.a(small14),.b(small16),.aidx(index[28]),.bidx(index[32]),.out1(big19),.out2(small19),.out1idx(index[37]),.out2idx(index[38]));
            assign OUT_character={index[17],index[33],index[34],index[35],index[36],index[37],index[38],index[24]};
        end
        default:begin
            assign a=0;
            assign b=0;
            assign c=0;
            assign d=0;
            assign e=0;
            assign f=0;
            assign g=0;
            assign h=0;
            assign index[1]=0;
            assign index[2]=0;
            assign index[3]=0;
            assign index[4]=0;
            assign index[5]=0;
            assign index[6]=0;
            assign index[7]=0;
            assign index[8]=0;
            assign index[9]=0;
            assign index[10]=0;
            assign index[11]=0;
            assign index[12]=0;
            assign index[13]=0;
            assign index[14]=0;
            assign index[15]=0;
            assign index[16]=0;
            assign index[17]=0;
            assign index[18]=0;
            assign index[19]=0;
            assign index[20]=0;
            assign index[21]=0;
            assign index[22]=0;
            assign index[23]=0;
            assign index[24]=0;
            assign index[25]=0;
            assign index[26]=0;
            assign index[27]=0;
            assign index[28]=0;
            assign index[29]=0;
            assign index[30]=0;
            assign index[31]=0;
            assign index[32]=0;
            assign index[33]=0;
            assign index[34]=0;
            assign index[35]=0;
            assign index[36]=0;
            assign index[37]=0;
            assign index[38]=0;
            assign big1=0;
            assign big2=0;
            assign big3=0;
            assign big4=0;
            assign big5=0;
            assign big6=0;
            assign big7=0;
            assign big8=0;
            assign big9=0;
            assign big10=0;
            assign big11=0;
            assign big12=0;
            assign big13=0;
            assign big14=0;
            assign big15=0;
            assign big16=0;
            assign big17=0;
            assign big18=0;
            assign big19=0;
            assign small1=0;
            assign small2=0;
            assign small3=0;
            assign small4=0;
            assign small5=0;
            assign small6=0;
            assign small7=0;
            assign small8=0;
            assign small9=0;
            assign small10=0;
            assign small11=0;
            assign small12=0;
            assign small13=0;
            assign small14=0;
            assign small15=0;
            assign small16=0;
            assign small17=0;
            assign small18=0;
            assign small19=0;
        end
    endcase
endgenerate

endmodule

module cmp(a,b,aidx,bidx,out1,out2,out1idx,out2idx);
input[4:0]a,b;
input[3:0]aidx,bidx;
output reg [4:0]out1,out2;
output reg [3:0]out1idx,out2idx;

always @(*) begin
    if (a>b) begin
        out1=a;
        out2=b;
        out1idx=aidx;
        out2idx=bidx;
    end
    else if (a==b) begin
        if (aidx>bidx) begin
            out1=a;
            out2=b;
            out1idx=aidx;
            out2idx=bidx;
        end
        else begin
            out1=b;
            out2=a;
            out1idx=bidx;
            out2idx=aidx;
        end
    end
    else begin
        out1=b;
        out2=a;
        out1idx=bidx;
        out2idx=aidx;
    end
end
endmodule
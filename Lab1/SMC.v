//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   (C) Copyright Laboratory System Integration and Silicon Implementation
//   All Right Reserved
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   ICLAB 2023 Fall
//   Lab01 Exercise		: Supper MOSFET Calculator
//   Author     		: Lin-Hung Lai (lhlai@ieee.org)
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   File Name   : SMC.v
//   Module Name : SMC
//   Release version : V1.0 (Release Date: 2023-09)
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################


module SMC(
  // Input signals
    mode,
    W_0, V_GS_0, V_DS_0,
    W_1, V_GS_1, V_DS_1,
    W_2, V_GS_2, V_DS_2,
    W_3, V_GS_3, V_DS_3,
    W_4, V_GS_4, V_DS_4,
    W_5, V_GS_5, V_DS_5,   
  // Output signals
    out_n
);

//================================================================
//   INPUT AND OUTPUT DECLARATION                         
//================================================================
input [2:0] W_0, V_GS_0, V_DS_0;
input [2:0] W_1, V_GS_1, V_DS_1;
input [2:0] W_2, V_GS_2, V_DS_2;
input [2:0] W_3, V_GS_3, V_DS_3;
input [2:0] W_4, V_GS_4, V_DS_4;
input [2:0] W_5, V_GS_5, V_DS_5;
input [1:0] mode;        					
output reg [7:0] out_n; 								
wire [7:0]calresult[0:5];
reg[6:0]n[0:2];
reg [7:0]out_reg;
Calculate c1(.Vgs(V_GS_0),.Vds(V_DS_0),.W(W_0),.mode_0(mode[0]),.out_reg(calresult[0]));
Calculate c2(.Vgs(V_GS_1),.Vds(V_DS_1),.W(W_1),.mode_0(mode[0]),.out_reg(calresult[1]));
Calculate c3(.Vgs(V_GS_2),.Vds(V_DS_2),.W(W_2),.mode_0(mode[0]),.out_reg(calresult[2]));
Calculate c4(.Vgs(V_GS_3),.Vds(V_DS_3),.W(W_3),.mode_0(mode[0]),.out_reg(calresult[3]));
Calculate c5(.Vgs(V_GS_4),.Vds(V_DS_4),.W(W_4),.mode_0(mode[0]),.out_reg(calresult[4]));
Calculate c6(.Vgs(V_GS_5),.Vds(V_DS_5),.W(W_5),.mode_0(mode[0]),.out_reg(calresult[5]));
FindMaxOrMinThree f1(.calresult1(calresult[0]),.calresult2(calresult[1]),.calresult3(calresult[2]),.calresult4(calresult[3]),.calresult5(calresult[4]),.calresult6(calresult[5]),.mode_1(mode[1]),.biggest(n[0]),.median(n[1]),.smallest(n[2]));
always @(*)begin
  case (mode[0])
    1'b1:out_reg=((3*n[0]+5*n[2])>>2)+n[1];
    1'b0:out_reg=n[0]+n[1]+n[2];
  endcase
end
always @(*) begin
  case (out_reg)
    8'h0: out_n = 8'h0;
    8'h1: out_n = 8'h0;
    8'h2: out_n = 8'h0;
    8'h3: out_n = 8'h1;
    8'h4: out_n = 8'h1;
    8'h5: out_n = 8'h1;
    8'h6: out_n = 8'h2;
    8'h7: out_n = 8'h2;
    8'h8: out_n = 8'h2;
    8'h9: out_n = 8'h3;
    8'ha: out_n = 8'h3;
    8'hb: out_n = 8'h3;
    8'hc: out_n = 8'h4;
    8'hd: out_n = 8'h4;
    8'he: out_n = 8'h4;
    8'hf: out_n = 8'h5;
    8'h10: out_n = 8'h5;
    8'h11: out_n = 8'h5;
    8'h12: out_n = 8'h6;
    8'h13: out_n = 8'h6;
    8'h14: out_n = 8'h6;
    8'h15: out_n = 8'h7;
    8'h16: out_n = 8'h7;
    8'h17: out_n = 8'h7;
    8'h18: out_n = 8'h8;
    8'h19: out_n = 8'h8;
    8'h1a: out_n = 8'h8;
    8'h1b: out_n = 8'h9;
    8'h1c: out_n = 8'h9;
    8'h1d: out_n = 8'h9;
    8'h1e: out_n = 8'ha;
    8'h1f: out_n = 8'ha;
    8'h20: out_n = 8'ha;
    8'h21: out_n = 8'hb;
    8'h22: out_n = 8'hb;
    8'h23: out_n = 8'hb;
    8'h24: out_n = 8'hc;
    8'h25: out_n = 8'hc;
    8'h26: out_n = 8'hc;
    8'h27: out_n = 8'hd;
    8'h28: out_n = 8'hd;
    8'h29: out_n = 8'hd;
    8'h2a: out_n = 8'he;
    8'h2b: out_n = 8'he;
    8'h2c: out_n = 8'he;
    8'h2d: out_n = 8'hf;
    8'h2e: out_n = 8'hf;
    8'h2f: out_n = 8'hf;
    8'h30: out_n = 8'h10;
    8'h31: out_n = 8'h10;
    8'h32: out_n = 8'h10;
    8'h33: out_n = 8'h11;
    8'h34: out_n = 8'h11;
    8'h35: out_n = 8'h11;
    8'h36: out_n = 8'h12;
    8'h37: out_n = 8'h12;
    8'h38: out_n = 8'h12;
    8'h39: out_n = 8'h13;
    8'h3a: out_n = 8'h13;
    8'h3b: out_n = 8'h13;
    8'h3c: out_n = 8'h14;
    8'h3d: out_n = 8'h14;
    8'h3e: out_n = 8'h14;
    8'h3f: out_n = 8'h15;
    8'h40: out_n = 8'h15;
    8'h41: out_n = 8'h15;
    8'h42: out_n = 8'h16;
    8'h43: out_n = 8'h16;
    8'h44: out_n = 8'h16;
    8'h45: out_n = 8'h17;
    8'h46: out_n = 8'h17;
    8'h47: out_n = 8'h17;
    8'h48: out_n = 8'h18;
    8'h49: out_n = 8'h18;
    8'h4a: out_n = 8'h18;
    8'h4b: out_n = 8'h19;
    8'h4c: out_n = 8'h19;
    8'h4d: out_n = 8'h19;
    8'h4e: out_n = 8'h1a;
    8'h4f: out_n = 8'h1a;
    8'h50: out_n = 8'h1a;
    8'h51: out_n = 8'h1b;
    8'h52: out_n = 8'h1b;
    8'h53: out_n = 8'h1b;
    8'h54: out_n = 8'h1c;
    8'h55: out_n = 8'h1c;
    8'h56: out_n = 8'h1c;
    8'h57: out_n = 8'h1d;
    8'h58: out_n = 8'h1d;
    8'h59: out_n = 8'h1d;
    8'h5a: out_n = 8'h1e;
    8'h5b: out_n = 8'h1e;
    8'h5c: out_n = 8'h1e;
    8'h5d: out_n = 8'h1f;
    8'h5e: out_n = 8'h1f;
    8'h5f: out_n = 8'h1f;
    8'h60: out_n = 8'h20;
    8'h61: out_n = 8'h20;
    8'h62: out_n = 8'h20;
    8'h63: out_n = 8'h21;
    8'h64: out_n = 8'h21;
    8'h65: out_n = 8'h21;
    8'h66: out_n = 8'h22;
    8'h67: out_n = 8'h22;
    8'h68: out_n = 8'h22;
    8'h69: out_n = 8'h23;
    8'h6a: out_n = 8'h23;
    8'h6b: out_n = 8'h23;
    8'h6c: out_n = 8'h24;
    8'h6d: out_n = 8'h24;
    8'h6e: out_n = 8'h24;
    8'h6f: out_n = 8'h25;
    8'h70: out_n = 8'h25;
    8'h71: out_n = 8'h25;
    8'h72: out_n = 8'h26;
    8'h73: out_n = 8'h26;
    8'h74: out_n = 8'h26;
    8'h75: out_n = 8'h27;
    8'h76: out_n = 8'h27;
    8'h77: out_n = 8'h27;
    8'h78: out_n = 8'h28;
    8'h79: out_n = 8'h28;
    8'h7a: out_n = 8'h28;
    8'h7b: out_n = 8'h29;
    8'h7c: out_n = 8'h29;
    8'h7d: out_n = 8'h29;
    8'h7e: out_n = 8'h2a;
    8'h7f: out_n = 8'h2a;
    8'h80: out_n = 8'h2a;
    8'h81: out_n = 8'h2b;
    8'h82: out_n = 8'h2b;
    8'h83: out_n = 8'h2b;
    8'h84: out_n = 8'h2c;
    8'h85: out_n = 8'h2c;
    8'h86: out_n = 8'h2c;
    8'h87: out_n = 8'h2d;
    8'h88: out_n = 8'h2d;
    8'h89: out_n = 8'h2d;
    8'h8a: out_n = 8'h2e;
    8'h8b: out_n = 8'h2e;
    8'h8c: out_n = 8'h2e;
    8'h8d: out_n = 8'h2f;
    8'h8e: out_n = 8'h2f;
    8'h8f: out_n = 8'h2f;
    8'h90: out_n = 8'h30;
    8'h91: out_n = 8'h30;
    8'h92: out_n = 8'h30;
    8'h93: out_n = 8'h31;
    8'h94: out_n = 8'h31;
    8'h95: out_n = 8'h31;
    8'h96: out_n = 8'h32;
    8'h97: out_n = 8'h32;
    8'h98: out_n = 8'h32;
    8'h99: out_n = 8'h33;
    8'h9a: out_n = 8'h33;
    8'h9b: out_n = 8'h33;
    8'h9c: out_n = 8'h34;
    8'h9d: out_n = 8'h34;
    8'h9e: out_n = 8'h34;
    8'h9f: out_n = 8'h35;
    8'ha0: out_n = 8'h35;
    8'ha1: out_n = 8'h35;
    8'ha2: out_n = 8'h36;
    8'ha3: out_n = 8'h36;
    8'ha4: out_n = 8'h36;
    8'ha5: out_n = 8'h37;
    8'ha6: out_n = 8'h37;
    8'ha7: out_n = 8'h37;
    8'ha8: out_n = 8'h38;
    8'ha9: out_n = 8'h38;
    8'haa: out_n = 8'h38;
    8'hab: out_n = 8'h39;
    8'hac: out_n = 8'h39;
    8'had: out_n = 8'h39;
    8'hae: out_n = 8'h3a;
    8'haf: out_n = 8'h3a;
    8'hb0: out_n = 8'h3a;
    8'hb1: out_n = 8'h3b;
    8'hb2: out_n = 8'h3b;
    8'hb3: out_n = 8'h3b;
    8'hb4: out_n = 8'h3c;
    8'hb5: out_n = 8'h3c;
    8'hb6: out_n = 8'h3c;
    8'hb7: out_n = 8'h3d;
    8'hb8: out_n = 8'h3d;
    8'hb9: out_n = 8'h3d;
    8'hba: out_n = 8'h3e;
    8'hbb: out_n = 8'h3e;
    8'hbc: out_n = 8'h3e;
    8'hbd: out_n = 8'h3f;
    8'hbe: out_n = 8'h3f;
    8'hbf: out_n = 8'h3f;
    8'hc0: out_n = 8'h40;
    8'hc1: out_n = 8'h40;
    8'hc2: out_n = 8'h40;
    8'hc3: out_n = 8'h41;
    8'hc4: out_n = 8'h41;
    8'hc5: out_n = 8'h41;
    8'hc6: out_n = 8'h42;
    8'hc7: out_n = 8'h42;
    8'hc8: out_n = 8'h42;
    8'hc9: out_n = 8'h43;
    8'hca: out_n = 8'h43;
    8'hcb: out_n = 8'h43;
    8'hcc: out_n = 8'h44;
    8'hcd: out_n = 8'h44;
    8'hce: out_n = 8'h44;
    8'hcf: out_n = 8'h45;
    8'hd0: out_n = 8'h45;
    8'hd1: out_n = 8'h45;
    8'hd2: out_n = 8'h46;
    8'hd3: out_n = 8'h46;
    8'hd4: out_n = 8'h46;
    8'hd5: out_n = 8'h47;
    8'hd6: out_n = 8'h47;
    8'hd7: out_n = 8'h47;
    8'hd8: out_n = 8'h48;
    8'hd9: out_n = 8'h48;
    8'hda: out_n = 8'h48;
    8'hdb: out_n = 8'h49;
    8'hdc: out_n = 8'h49;
    8'hdd: out_n = 8'h49;
    8'hde: out_n = 8'h4a;
    8'hdf: out_n = 8'h4a;
    8'he0: out_n = 8'h4a;
    8'he1: out_n = 8'h4b;
    8'he2: out_n = 8'h4b;
    8'he3: out_n = 8'h4b;
    8'he4: out_n = 8'h4c;
    8'he5: out_n = 8'h4c;
    8'he6: out_n = 8'h4c;
    8'he7: out_n = 8'h4d;
    8'he8: out_n = 8'h4d;
    8'he9: out_n = 8'h4d;
    8'hea: out_n = 8'h4e;
    8'heb: out_n = 8'h4e;
    8'hec: out_n = 8'h4e;
    8'hed: out_n = 8'h4f;
    8'hee: out_n = 8'h4f;
    8'hef: out_n = 8'h4f;
    8'hf0: out_n = 8'h50;
    8'hf1: out_n = 8'h50;
    8'hf2: out_n = 8'h50;
    8'hf3: out_n = 8'h51;
    8'hf4: out_n = 8'h51;
    8'hf5: out_n = 8'h51;
    8'hf6: out_n = 8'h52;
    8'hf7: out_n = 8'h52;
    8'hf8: out_n = 8'h52;
    8'hf9: out_n = 8'h53;
    8'hfa: out_n = 8'h53;
    8'hfb: out_n = 8'h53;
    8'hfc: out_n = 8'h54;
    8'hfd: out_n = 8'h54;
    8'hfe: out_n = 8'h54;
    8'hff: out_n = 8'h55;
  endcase
end
endmodule
module Calculate (Vgs,Vds,W,mode_0,out_reg);
input [2:0] W, Vgs, Vds;
input mode_0;
output [7:0]out_reg;
reg [2:0] VgssubVth;
reg [5:0] result;
wire operationmode;
always @(*) begin
  case (Vgs)
    3'd7:VgssubVth=3'd6;
    3'd6:VgssubVth=3'd5;
    3'd5:VgssubVth=3'd4;
    3'd4:VgssubVth=3'd3;
    3'd3:VgssubVth=3'd2;
    3'd2:VgssubVth=3'd1;
    default:VgssubVth=3'd0;
  endcase
end
assign operationmode=VgssubVth>Vds;
always @(*) begin
  case(mode_0)
  1'b0:begin
      result=(operationmode?Vds:VgssubVth)<<1;
  end
  1'b1:begin
      case (operationmode)
        1'b1:begin
          case (Vds)
            3'd1:begin
              case (VgssubVth)
              3'd6:result=6'd11;
              3'd5:result=6'd9;
              3'd4:result=6'd7;
              3'd3:result=6'd5;
              3'd2:result=6'd3;
              default:result=6'd0; 
            endcase
            end
            3'd2:begin
              case (VgssubVth)
              3'd6:result=6'd20;
              3'd5:result=6'd16;
              3'd4:result=6'd12;
              3'd3:result=6'd8;
              default:result=6'd0;
              endcase
            end
            3'd3:begin
              case (VgssubVth)
              3'd6:result=6'd27;
              3'd5:result=6'd21;
              3'd4:result=6'd15;
              default:result=6'd0;
              endcase
            end
            3'd4:begin
              case (VgssubVth)
              3'd6:result=6'd32;
              3'd5:result=6'd24;
              default:result=6'd0;
              endcase
            end
            3'd5:begin
              case (VgssubVth)
              3'd6:result=6'd35;
              default:result=6'd0;
              endcase
            end
            default :result=6'd0;
          endcase 
          end
        1'b0:begin
          case (VgssubVth)
            3'b110:result=6'd36;
            3'b101:result=6'd25;
            3'b100:result=6'd16;
            3'b011:result=6'd9;
            3'b010:result=6'd4;
            3'b001:result=6'd1;
            default:result=6'd0; 
          endcase
        end 
      endcase
  end 
  //result=(VgssubVth>Vds)?(Vds*(2*VgssubVth-Vds)):(VgssubVth*VgssubVth);
  endcase
end
assign out_reg=result*W;
endmodule
module FindMaxOrMinThree (calresult1,calresult2,calresult3,calresult4,calresult5,calresult6,mode_1,biggest,median,smallest);
input [7:0]calresult1,calresult2,calresult3,calresult4,calresult5,calresult6;
input mode_1;
output [6:0]biggest,median,smallest;
reg [7:0]x[0:5];
reg [7:0] larger1,smaller1;
reg [7:0] larger2,smaller2;
reg [7:0] larger3,smaller3;
reg [7:0] one,two,three,four;
reg [7:0] tmp_1,tmp_2;
reg [7:0] tmp1,tmp2,tmp3;
reg [7:0] tmpone;
reg [7:0] tmptwo;
always @(*) begin
  case (mode_1)
    1'b1:begin
      x[0]=calresult1;
      x[1]=calresult2;
      x[2]=calresult3;
      x[3]=calresult4;
      x[4]=calresult5;
      x[5]=calresult6;
    end
    1'b0:begin
      x[0]=~calresult1;
      x[1]=~calresult2;
      x[2]=~calresult3;
      x[3]=~calresult4;
      x[4]=~calresult5;
      x[5]=~calresult6;
    end
  endcase
end
always @(*) begin
  {larger1,smaller1} = (x[0] >= x[1])?{x[0],x[1]}:{x[1],x[0]};
  {larger2,smaller2} = (x[2] >= x[3])?{x[2],x[3]}:{x[3],x[2]};
  {larger3,smaller3} = (x[4] >= x[5])?{x[4],x[5]}:{x[5],x[4]};
  {one,tmp_1} = (larger1 >= larger2)?{larger1,larger2}:{larger2,larger1};
  {tmp_2,four} = (smaller1 >= smaller2)?{smaller1,smaller2}:{smaller2,smaller1};
  {two,three} = (tmp_1 >= tmp_2)?{tmp_1,tmp_2}:{tmp_2,tmp_1};
  if (larger3>=three) begin
    tmpone=one;
    tmptwo=two;
    if (larger3 >= two) begin
      if (larger3 >= one) begin
        one = larger3;
        if (smaller3 >= tmpone) begin
        two = smaller3;
        three=tmpone;
        end 
        else if (smaller3 >= tmptwo) begin
          two = tmpone;
          three=smaller3;
        end
        else begin
          two=tmpone;
          three=tmptwo;
        end
      end else if (smaller3 >= tmptwo) begin
        two = larger3;
        three = smaller3;
      end else begin
        two=larger3;
        three=tmptwo;
      end
    end else begin
        three = larger3;
      end
  end
  case (mode_1)
    1'b1:begin
      tmp1=one;
      tmp2=two;
      tmp3=three;
    end
    1'b0:begin
      tmp1=~three;
      tmp2=~two;
      tmp3=~one;
    end
  endcase
end

div3 d1(.in(tmp1),.out(biggest));
div3 d2(.in(tmp2),.out(median));
div3 d3(.in(tmp3),.out(smallest));
endmodule
module div3(in,out);
input[7:0]in;
output reg[6:0]out;
always @(*) begin
  case (in)
    8'h0: out = 7'h0;
    8'h1: out = 7'h0;
    8'h2: out = 7'h0;
    8'h3: out = 7'h1;
    8'h4: out = 7'h1;
    8'h5: out = 7'h1;
    8'h6: out = 7'h2;
    8'h7: out = 7'h2;
    8'h8: out = 7'h2;
    8'h9: out = 7'h3;
    8'ha: out = 7'h3;
    8'hb: out = 7'h3;
    8'hc: out = 7'h4;
    8'hd: out = 7'h4;
    8'he: out = 7'h4;
    8'hf: out = 7'h5;
    8'h10: out = 7'h5;
    8'h11: out = 7'h5;
    8'h12: out = 7'h6;
    8'h13: out = 7'h6;
    8'h14: out = 7'h6;
    8'h15: out = 7'h7;
    8'h16: out = 7'h7;
    8'h17: out = 7'h7;
    8'h18: out = 7'h8;
    8'h19: out = 7'h8;
    8'h1a: out = 7'h8;
    8'h1b: out = 7'h9;
    8'h1c: out = 7'h9;
    8'h1d: out = 7'h9;
    8'h1e: out = 7'ha;
    8'h1f: out = 7'ha;
    8'h20: out = 7'ha;
    8'h21: out = 7'hb;
    8'h22: out = 7'hb;
    8'h23: out = 7'hb;
    8'h24: out = 7'hc;
    8'h25: out = 7'hc;
    8'h26: out = 7'hc;
    8'h27: out = 7'hd;
    8'h28: out = 7'hd;
    8'h29: out = 7'hd;
    8'h2a: out = 7'he;
    8'h2b: out = 7'he;
    8'h2c: out = 7'he;
    8'h2d: out = 7'hf;
    8'h2e: out = 7'hf;
    8'h2f: out = 7'hf;
    8'h30: out = 7'h10;
    8'h31: out = 7'h10;
    8'h32: out = 7'h10;
    8'h33: out = 7'h11;
    8'h34: out = 7'h11;
    8'h35: out = 7'h11;
    8'h36: out = 7'h12;
    8'h37: out = 7'h12;
    8'h38: out = 7'h12;
    8'h39: out = 7'h13;
    8'h3a: out = 7'h13;
    8'h3b: out = 7'h13;
    8'h3c: out = 7'h14;
    8'h3d: out = 7'h14;
    8'h3e: out = 7'h14;
    8'h3f: out = 7'h15;
    8'h40: out = 7'h15;
    8'h41: out = 7'h15;
    8'h42: out = 7'h16;
    8'h43: out = 7'h16;
    8'h44: out = 7'h16;
    8'h45: out = 7'h17;
    8'h46: out = 7'h17;
    8'h47: out = 7'h17;
    8'h48: out = 7'h18;
    8'h49: out = 7'h18;
    8'h4a: out = 7'h18;
    8'h4b: out = 7'h19;
    8'h4c: out = 7'h19;
    8'h4d: out = 7'h19;
    8'h4e: out = 7'h1a;
    8'h4f: out = 7'h1a;
    8'h50: out = 7'h1a;
    8'h51: out = 7'h1b;
    8'h52: out = 7'h1b;
    8'h53: out = 7'h1b;
    8'h54: out = 7'h1c;
    8'h55: out = 7'h1c;
    8'h56: out = 7'h1c;
    8'h57: out = 7'h1d;
    8'h58: out = 7'h1d;
    8'h59: out = 7'h1d;
    8'h5a: out = 7'h1e;
    8'h5b: out = 7'h1e;
    8'h5c: out = 7'h1e;
    8'h5d: out = 7'h1f;
    8'h5e: out = 7'h1f;
    8'h5f: out = 7'h1f;
    8'h60: out = 7'h20;
    8'h61: out = 7'h20;
    8'h62: out = 7'h20;
    8'h63: out = 7'h21;
    8'h64: out = 7'h21;
    8'h65: out = 7'h21;
    8'h66: out = 7'h22;
    8'h67: out = 7'h22;
    8'h68: out = 7'h22;
    8'h69: out = 7'h23;
    8'h6a: out = 7'h23;
    8'h6b: out = 7'h23;
    8'h6c: out = 7'h24;
    8'h6d: out = 7'h24;
    8'h6e: out = 7'h24;
    8'h6f: out = 7'h25;
    8'h70: out = 7'h25;
    8'h71: out = 7'h25;
    8'h72: out = 7'h26;
    8'h73: out = 7'h26;
    8'h74: out = 7'h26;
    8'h75: out = 7'h27;
    8'h76: out = 7'h27;
    8'h77: out = 7'h27;
    8'h78: out = 7'h28;
    8'h79: out = 7'h28;
    8'h7a: out = 7'h28;
    8'h7b: out = 7'h29;
    8'h7c: out = 7'h29;
    8'h7d: out = 7'h29;
    8'h7e: out = 7'h2a;
    8'h7f: out = 7'h2a;
    8'h80: out = 7'h2a;
    8'h81: out = 7'h2b;
    8'h82: out = 7'h2b;
    8'h83: out = 7'h2b;
    8'h84: out = 7'h2c;
    8'h85: out = 7'h2c;
    8'h86: out = 7'h2c;
    8'h87: out = 7'h2d;
    8'h88: out = 7'h2d;
    8'h89: out = 7'h2d;
    8'h8a: out = 7'h2e;
    8'h8b: out = 7'h2e;
    8'h8c: out = 7'h2e;
    8'h8d: out = 7'h2f;
    8'h8e: out = 7'h2f;
    8'h8f: out = 7'h2f;
    8'h90: out = 7'h30;
    8'h91: out = 7'h30;
    8'h92: out = 7'h30;
    8'h93: out = 7'h31;
    8'h94: out = 7'h31;
    8'h95: out = 7'h31;
    8'h96: out = 7'h32;
    8'h97: out = 7'h32;
    8'h98: out = 7'h32;
    8'h99: out = 7'h33;
    8'h9a: out = 7'h33;
    8'h9b: out = 7'h33;
    8'h9c: out = 7'h34;
    8'h9d: out = 7'h34;
    8'h9e: out = 7'h34;
    8'h9f: out = 7'h35;
    8'ha0: out = 7'h35;
    8'ha1: out = 7'h35;
    8'ha2: out = 7'h36;
    8'ha3: out = 7'h36;
    8'ha4: out = 7'h36;
    8'ha5: out = 7'h37;
    8'ha6: out = 7'h37;
    8'ha7: out = 7'h37;
    8'ha8: out = 7'h38;
    8'ha9: out = 7'h38;
    8'haa: out = 7'h38;
    8'hab: out = 7'h39;
    8'hac: out = 7'h39;
    8'had: out = 7'h39;
    8'hae: out = 7'h3a;
    8'haf: out = 7'h3a;
    8'hb0: out = 7'h3a;
    8'hb1: out = 7'h3b;
    8'hb2: out = 7'h3b;
    8'hb3: out = 7'h3b;
    8'hb4: out = 7'h3c;
    8'hb5: out = 7'h3c;
    8'hb6: out = 7'h3c;
    8'hb7: out = 7'h3d;
    8'hb8: out = 7'h3d;
    8'hb9: out = 7'h3d;
    8'hba: out = 7'h3e;
    8'hbb: out = 7'h3e;
    8'hbc: out = 7'h3e;
    8'hbd: out = 7'h3f;
    8'hbe: out = 7'h3f;
    8'hbf: out = 7'h3f;
    8'hc0: out = 7'h40;
    8'hc1: out = 7'h40;
    8'hc2: out = 7'h40;
    8'hc3: out = 7'h41;
    8'hc4: out = 7'h41;
    8'hc5: out = 7'h41;
    8'hc6: out = 7'h42;
    8'hc7: out = 7'h42;
    8'hc8: out = 7'h42;
    8'hc9: out = 7'h43;
    8'hca: out = 7'h43;
    8'hcb: out = 7'h43;
    8'hcc: out = 7'h44;
    8'hcd: out = 7'h44;
    8'hce: out = 7'h44;
    8'hcf: out = 7'h45;
    8'hd0: out = 7'h45;
    8'hd1: out = 7'h45;
    8'hd2: out = 7'h46;
    8'hd3: out = 7'h46;
    8'hd4: out = 7'h46;
    8'hd5: out = 7'h47;
    8'hd6: out = 7'h47;
    8'hd7: out = 7'h47;
    8'hd8: out = 7'h48;
    8'hd9: out = 7'h48;
    8'hda: out = 7'h48;
    8'hdb: out = 7'h49;
    8'hdc: out = 7'h49;
    8'hdd: out = 7'h49;
    8'hde: out = 7'h4a;
    8'hdf: out = 7'h4a;
    8'he0: out = 7'h4a;
    8'he1: out = 7'h4b;
    8'he2: out = 7'h4b;
    8'he3: out = 7'h4b;
    8'he4: out = 7'h4c;
    8'he5: out = 7'h4c;
    8'he6: out = 7'h4c;
    8'he7: out = 7'h4d;
    8'he8: out = 7'h4d;
    8'he9: out = 7'h4d;
    8'hea: out = 7'h4e;
    8'heb: out = 7'h4e;
    8'hec: out = 7'h4e;
    8'hed: out = 7'h4f;
    8'hee: out = 7'h4f;
    8'hef: out = 7'h4f;
    8'hf0: out = 7'h50;
    8'hf1: out = 7'h50;
    8'hf2: out = 7'h50;
    8'hf3: out = 7'h51;
    8'hf4: out = 7'h51;
    8'hf5: out = 7'h51;
    8'hf6: out = 7'h52;
    8'hf7: out = 7'h52;
    8'hf8: out = 7'h52;
    8'hf9: out = 7'h53;
    8'hfa: out = 7'h53;
    8'hfb: out = 7'h53;
    8'hfc: out = 7'h54;
    8'hfd: out = 7'h54;
    8'hfe: out = 7'h54;
    8'hff: out = 7'h55;
  endcase
end
endmodule
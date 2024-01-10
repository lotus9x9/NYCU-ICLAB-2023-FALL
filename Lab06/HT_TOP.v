//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//    (C) Copyright System Integration and Silicon Implementation Laboratory
//    All Right Reserved
//		Date		: 2023/10
//		Version		: v1.0
//   	File Name   : HT_TOP.v
//   	Module Name : HT_TOP
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################

//synopsys translate_off
`include "SORT_IP.v"
//synopsys translate_on

module HT_TOP(
    // Input signals
    clk,
	rst_n,
	in_valid,
    in_weight, 
	out_mode,
    // Output signals
    out_valid, 
	out_code
);

// ===============================================================
// Input & Output Declaration
// ===============================================================
input clk, rst_n, in_valid, out_mode;
input [2:0] in_weight;

output reg out_valid, out_code;

parameter idle=0;
parameter out0_1=1;
parameter out0_2=2;
parameter out0_3=3;
parameter out0_4=4;
parameter out0_5=5;
// ===============================================================
// Reg & Wire Declaration
// ===============================================================
reg [2:0]state,nextstate;
reg [4:0]weightreg[2:15];
reg [3:0]inputcnt;
reg [3:0]clkcnt;
reg modereg;
reg [2:0]mask[0:7];
reg [6:0]huffcode[0:7];
reg [2:0]cntstart7;
reg [31:0]sortchar;
reg [39:0]sortweight;
reg [31:0]sortout;
reg [31:0]sortoutff;
reg [7:0]cellintree[2:15];
reg [2:0]outcnt;
reg [2:0]tmpmask;
reg [6:0]tmpcode;
// ===============================================================
// Design
// ===============================================================
//INPUT
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) inputcnt<=15;
    else begin
        if (in_valid) begin
            inputcnt<=inputcnt-1;
        end
        else inputcnt<=15;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (integer i =2 ;i<16 ;i=i+1 ) begin
            weightreg[i]<=0;
        end
    end
    else begin
        if (in_valid) begin
            weightreg[inputcnt]<=in_weight;   
        end
        else begin
            weightreg[cntstart7]<=weightreg[sortout[7:4]]+weightreg[sortout[3:0]];
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)modereg<=0;
    else begin
        if (in_valid&&inputcnt==15) modereg<=out_mode;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) clkcnt<=0;
    else begin
        if(state==out0_1)clkcnt<=0;
        else if (clkcnt>=1) clkcnt<=clkcnt+1;
        else if(in_valid)clkcnt<=1; 
    end
end
//FSM
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) state<=idle;
    else state<=nextstate;
end
always @(*) begin
    case (state)
        idle:begin
            if(clkcnt==13) nextstate=out0_1;
            else nextstate=idle;
        end 
        out0_1:begin
            if(outcnt==tmpmask) nextstate=out0_2;
            else nextstate=out0_1;
        end
        out0_2:begin
            if(outcnt==tmpmask) nextstate=out0_3;
            else nextstate=out0_2;
        end
        out0_3:begin
            if(outcnt==tmpmask) nextstate=out0_4;
            else nextstate=out0_3;
        end
        out0_4:begin
            if(outcnt==tmpmask) nextstate=out0_5;
            else nextstate=out0_4;
        end
        out0_5:begin
            if(outcnt==tmpmask) nextstate=idle;
            else nextstate=out0_5;
        end
        default:nextstate=idle;
    endcase
end
//Output
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        outcnt<=0;
    end
    else begin
        if(outcnt==tmpmask) outcnt<=0;
        else outcnt<=outcnt+1;
    end
end
always @(*) begin
    case(state)
        out0_1:begin
            tmpmask=mask[4];
            tmpcode=huffcode[4];
        end
        out0_2:begin
            tmpmask=modereg?mask[2]:mask[5];
            tmpcode=modereg?huffcode[2]:huffcode[5];
        end
        out0_3:begin
            tmpmask=modereg?mask[5]:mask[6];
            tmpcode=modereg?huffcode[5]:huffcode[6];
        end
        out0_4:begin
            tmpmask=modereg?mask[0]:mask[7];
            tmpcode=modereg?huffcode[0]:huffcode[7];
        end
        out0_5:begin
            tmpmask=modereg?mask[1]:mask[3];
            tmpcode=modereg?huffcode[1]:huffcode[3];
        end
        default:begin
            tmpmask=0;
            tmpcode=0;
        end
    endcase
end
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)out_valid<=1'b0;
    else begin
        if (state==out0_1) out_valid<=1'b1;
        else if(state==idle) out_valid<=1'b0;
    end
end
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) out_code<=0;
    else begin
        if (state==out0_1)begin
            if(outcnt==0)begin
                if ((cellintree[sortout[7:4]][3]==1'b1)) out_code<=1'b0;
                else out_code<=1'b1;
            end
            else out_code<=tmpcode[outcnt];
        end
        else if(state>=out0_2&&state<=out0_5)out_code<=tmpcode[outcnt];
        else out_code<=0; 
    end
end
//CAL
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) cntstart7<=0;
    else begin
        if(clkcnt>=8) cntstart7<=cntstart7-1;
        else if (clkcnt==7) cntstart7<=7;
        else cntstart7<=0;
    end
end

always @(*) begin
    case (cntstart7)
        3'd7:begin
            sortchar={4'd15,4'd14,4'd13,4'd12,4'd11,4'd10,4'd9,4'd8};
            sortweight={weightreg[15],weightreg[14],weightreg[13],weightreg[12],weightreg[11],weightreg[10],weightreg[9],weightreg[8]};
        end
        3'd6:begin
            sortchar={sortoutff[31:8],4'd7,4'd15};
            sortweight={weightreg[sortoutff[31:28]],weightreg[sortoutff[27:24]],weightreg[sortoutff[23:20]],weightreg[sortoutff[19:16]],weightreg[sortoutff[15:12]],weightreg[sortoutff[11:8]],weightreg[7],5'd31};
        end
        3'd5:begin
            sortchar={sortoutff[27:8],4'd6,4'd15,4'd15};
            sortweight={weightreg[sortoutff[27:24]],weightreg[sortoutff[23:20]],weightreg[sortoutff[19:16]],weightreg[sortoutff[15:12]],weightreg[sortoutff[11:8]],weightreg[6],5'd31,5'd31};
        end
        3'd4:begin
            sortchar={sortoutff[23:8],4'd5,4'd15,4'd15,4'd15};
            sortweight={weightreg[sortoutff[23:20]],weightreg[sortoutff[19:16]],weightreg[sortoutff[15:12]],weightreg[sortoutff[11:8]],weightreg[5],5'd31,5'd31,5'd31};
        end
        3'd3:begin
            sortchar={sortoutff[19:8],4'd4,4'd15,4'd15,4'd15,4'd15};
            sortweight={weightreg[sortoutff[19:16]],weightreg[sortoutff[15:12]],weightreg[sortoutff[11:8]],weightreg[4],5'd31,5'd31,5'd31,5'd31};
        end
        3'd2:begin
            sortchar={sortoutff[15:8],4'd3,4'd15,4'd15,4'd15,4'd15,4'd15};
            sortweight={weightreg[sortoutff[15:12]],weightreg[sortoutff[11:8]],weightreg[3],5'd31,5'd31,5'd31,5'd31,5'd31};
        end
        3'd1:begin
            sortchar={sortoutff[11:8],4'd2,4'd15,4'd15,4'd15,4'd15,4'd15,4'd15};
            sortweight={weightreg[sortoutff[11:8]],weightreg[2],5'd31,5'd31,5'd31,5'd31,5'd31,5'd31};
        end
        default:begin
            sortchar=0;
            sortweight=0;
        end
    endcase
end
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) sortoutff<=0;
    else begin
        case (cntstart7)
            3'd7:sortoutff<=sortout;
            3'd6:sortoutff<=sortout;
            3'd5:sortoutff<=sortout;
            3'd4:sortoutff<=sortout;
            3'd3:sortoutff<=sortout;
            3'd2:sortoutff<=sortout;
            default:sortoutff<=0;
        endcase
    end
end

SORT_IP #(8) s1(.IN_character(sortchar),.IN_weight(sortweight),.OUT_character(sortout));

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (integer j =2 ;j<16 ;j=j+1 ) begin
            cellintree[j]<=0;
        end
    end
    else begin
        cellintree[15]<=8'b10000000;
        cellintree[14]<=8'b01000000;
        cellintree[13]<=8'b00100000;
        cellintree[12]<=8'b00010000;
        cellintree[11]<=8'b00001000;
        cellintree[10]<=8'b00000100;
        cellintree[9]<=8'b00000010;
        cellintree[8]<=8'b00000001;
        cellintree[cntstart7]<=cellintree[sortout[7:4]]|cellintree[sortout[3:0]];
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (integer i=0 ;i<8 ;i=i+1 ) begin
            huffcode[i]<=0;
            mask[i]<=0;
        end
    end
    else begin
        if (in_valid) begin
            for (integer i=0 ;i<8 ;i=i+1 ) begin
                mask[i]<=0;
            end
        end
        if (cntstart7<=7&&cntstart7>=2) begin
            if(cellintree[sortout[7:4]][0]==1'b1)begin
                mask[7]<=mask[7]+1;
                huffcode[7]<={huffcode[7][5:0],1'b0};
            end 
            if(cellintree[sortout[7:4]][1]==1'b1) begin
                mask[6]<=mask[6]+1;
                huffcode[6]<={huffcode[6][5:0],1'b0};
            end
            if(cellintree[sortout[7:4]][2]==1'b1) begin
                mask[5]<=mask[5]+1;
                huffcode[5]<={huffcode[5][5:0],1'b0};
            end
            if(cellintree[sortout[7:4]][3]==1'b1) begin
                mask[4]<=mask[4]+1;
                huffcode[4]<={huffcode[4][5:0],1'b0};
            end
            if(cellintree[sortout[7:4]][4]==1'b1) begin
                mask[3]<=mask[3]+1;
                huffcode[3]<={huffcode[3][5:0],1'b0};
            end
            if(cellintree[sortout[7:4]][5]==1'b1) begin
                mask[2]<=mask[2]+1;
                huffcode[2]<={huffcode[2][5:0],1'b0};
            end
            if(cellintree[sortout[7:4]][6]==1'b1) begin
                mask[1]<=mask[1]+1;
                huffcode[1]<={huffcode[1][5:0],1'b0};
            end
            if(cellintree[sortout[7:4]][7]==1'b1) begin
                mask[0]<=mask[0]+1;
                huffcode[0]<={huffcode[0][5:0],1'b0};
            end
            if(cellintree[sortout[3:0]][0]==1'b1) begin
                mask[7]<=mask[7]+1;
                huffcode[7]<={huffcode[7][5:0],1'b1};
            end
            if(cellintree[sortout[3:0]][1]==1'b1) begin
                mask[6]<=mask[6]+1;
                huffcode[6]<={huffcode[6][5:0],1'b1};
            end
            if(cellintree[sortout[3:0]][2]==1'b1) begin
                mask[5]<=mask[5]+1;
                huffcode[5]<={huffcode[5][5:0],1'b1};
            end
            if(cellintree[sortout[3:0]][3]==1'b1) begin
                mask[4]<=mask[4]+1;
                huffcode[4]<={huffcode[4][5:0],1'b1};
            end
            if(cellintree[sortout[3:0]][4]==1'b1) begin
                mask[3]<=mask[3]+1;
                huffcode[3]<={huffcode[3][5:0],1'b1};
            end
            if(cellintree[sortout[3:0]][5]==1'b1) begin
                mask[2]<=mask[2]+1;
                huffcode[2]<={huffcode[2][5:0],1'b1};
            end
            if(cellintree[sortout[3:0]][6]==1'b1) begin
                mask[1]<=mask[1]+1;
                huffcode[1]<={huffcode[1][5:0],1'b1};
            end
            if(cellintree[sortout[3:0]][7]==1'b1) begin
                mask[0]<=mask[0]+1;
                huffcode[0]<={huffcode[0][5:0],1'b1};
            end
        end
        if (cntstart7==1) begin
            if(cellintree[sortout[3:0]][0]==1'b1) huffcode[7]<={huffcode[7][5:0],1'b1};
            else huffcode[7]<={huffcode[7][5:0],1'b0};
            if(cellintree[sortout[3:0]][1]==1'b1) huffcode[6]<={huffcode[6][5:0],1'b1};
            else huffcode[6]<={huffcode[6][5:0],1'b0};
            if(cellintree[sortout[3:0]][2]==1'b1) huffcode[5]<={huffcode[5][5:0],1'b1};
            else huffcode[5]<={huffcode[5][5:0],1'b0};
            if(cellintree[sortout[3:0]][3]==1'b1) huffcode[4]<={huffcode[4][5:0],1'b1};
            else huffcode[4]<={huffcode[4][5:0],1'b0};
            if(cellintree[sortout[3:0]][4]==1'b1) huffcode[3]<={huffcode[3][5:0],1'b1};
            else huffcode[3]<={huffcode[3][5:0],1'b0};
            if(cellintree[sortout[3:0]][5]==1'b1) huffcode[2]<={huffcode[2][5:0],1'b1};
            else huffcode[2]<={huffcode[2][5:0],1'b0};
            if(cellintree[sortout[3:0]][6]==1'b1) huffcode[1]<={huffcode[1][5:0],1'b1};
            else huffcode[1]<={huffcode[1][5:0],1'b0};
            if(cellintree[sortout[3:0]][7]==1'b1) huffcode[0]<={huffcode[0][5:0],1'b1};
            else huffcode[0]<={huffcode[0][5:0],1'b0};
        end
    end
end

endmodule
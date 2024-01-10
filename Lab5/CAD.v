module CAD (
    clk,
    rst_n,
    in_valid,
    in_valid2,
    matrix_size,
    matrix,
    matrix_idx,
    mode,
    
    //Output Port
    out_valid,
    out_value
);

input clk,rst_n,in_valid,in_valid2,mode;
input[1:0]matrix_size;
input[7:0]matrix;
input[3:0]matrix_idx;

output reg out_valid;
output reg out_value;
reg modereg;
reg [15:0] imageaddr;
reg signed [7:0] imagedata;
reg [8:0]keraddr;
reg signed [7:0]kerdata;
reg [10:0]outaddrA,outaddrB;
reg signed [19:0]outraminA,outraminB;
reg signed [19:0]outdataA,outdataB;
reg outwebA,outwebB;
reg [1:0]sizereg;
reg [14:0]inputcnt;
reg [8:0]kernelcnt;
reg signed [7:0]matrixreg;
reg WEBIMAGE;
reg WEBKERNEL;
reg [3:0]imageidx,kernelidx;
reg [5:0]matrixlength;
reg [10:0]matrixsize;
reg [13:0]imageoffset;
reg [8:0]kerneloffset;
reg idxcnt;
reg [14:0]clkcnt;
reg [5:0]rowid,colid,tmpmaxrowid;
reg [2:0]cnt7;
reg [10:0]cntiteration;
reg [5:0]cntset;
reg [1:0]movectrl_cs,movectrl_ns;
reg signed [7:0]calmatrix[0:29];
reg signed [7:0]kernelmatrix[0:24];
reg signed [19:0]tmpsum,sum;
reg signed [7:0]tmp1,tmp2,tmp3,tmp4,tmp5,tmp6,tmp7,tmp8,tmp9,tmp10;
reg signed [19:0] maxpoolreg[0:13];
reg signed [19:0]tmpmax,tmpcmp1,tmpcmp2;
reg [6:0]cntmaxpool;
reg [7:0]cntmaxpooladdr;
reg signed [19:0]out_data;
reg [4:0]cnt20;
reg [10:0]cntformaxpoolsram;
reg [10:0]cntmode1index;
reg cntmaxpooltmp;
//SRAM
Img Img0 (.A0(imageaddr[0]), .A1(imageaddr[1]), .A2(imageaddr[2]), .A3(imageaddr[3]), .A4(imageaddr[4]), .A5(imageaddr[5]), .A6(imageaddr[6]), .A7(imageaddr[7]), .A8(imageaddr[8]), .A9(imageaddr[9]), .A10(imageaddr[10]), .A11(imageaddr[11]), .A12(imageaddr[12]), .A13(imageaddr[13]),.A14(imageaddr[14]),
            .DO0(imagedata[0]), .DO1(imagedata[1]), .DO2(imagedata[2]), .DO3(imagedata[3]), .DO4(imagedata[4]), .DO5(imagedata[5]), .DO6(imagedata[6]), .DO7(imagedata[7]), 
            .DI0(matrixreg[0]), .DI1(matrixreg[1]), .DI2(matrixreg[2]), .DI3(matrixreg[3]), .DI4(matrixreg[4]), .DI5(matrixreg[5]), .DI6(matrixreg[6]), .DI7(matrixreg[7]), 
            .CK(clk), .WEB(WEBIMAGE), .OE(1'b1), .CS(1'b1));
Kernel Kernel0 (.A0(keraddr[0]), .A1(keraddr[1]), .A2(keraddr[2]), .A3(keraddr[3]), .A4(keraddr[4]), .A5(keraddr[5]), .A6(keraddr[6]), .A7(keraddr[7]), .A8(keraddr[8]), 
                    .DO0(kerdata[0]), .DO1(kerdata[1]), .DO2(kerdata[2]), .DO3(kerdata[3]), .DO4(kerdata[4]), .DO5(kerdata[5]), .DO6(kerdata[6]), .DO7(kerdata[7]), 
                    .DI0(matrixreg[0]), .DI1(matrixreg[1]), .DI2(matrixreg[2]), .DI3(matrixreg[3]), .DI4(matrixreg[4]), .DI5(matrixreg[5]), .DI6(matrixreg[6]), .DI7(matrixreg[7]), 
                    .CK(clk), .WEB(WEBKERNEL), .OE(1'b1), .CS(1'b1));
Outputram Output0 (.A0(outaddrA[0]),.A1(outaddrA[1]),.A2(outaddrA[2]),.A3(outaddrA[3]),.A4(outaddrA[4]),.A5(outaddrA[5]),.A6(outaddrA[6]),.A7(outaddrA[7]),.A8(outaddrA[8]),.A9(outaddrA[9]),.A10(outaddrA[10]),
                .B0(outaddrB[0]),.B1(outaddrB[1]),.B2(outaddrB[2]),.B3(outaddrB[3]),.B4(outaddrB[4]),.B5(outaddrB[5]),.B6(outaddrB[6]),.B7(outaddrB[7]),.B8(outaddrB[8]),.B9(outaddrB[9]),.B10(outaddrB[10]),
                .DOA0(outdataA[0]),.DOA1(outdataA[1]),.DOA2(outdataA[2]),.DOA3(outdataA[3]),.DOA4(outdataA[4]),.DOA5(outdataA[5]),.DOA6(outdataA[6]),.DOA7(outdataA[7]),.DOA8(outdataA[8]),.DOA9(outdataA[9]),.DOA10(outdataA[10]),.DOA11(outdataA[11]),.DOA12(outdataA[12]),.DOA13(outdataA[13]),.DOA14(outdataA[14]),.DOA15(outdataA[15]),.DOA16(outdataA[16]),.DOA17(outdataA[17]),.DOA18(outdataA[18]),.DOA19(outdataA[19]),
                .DOB0(outdataB[0]),.DOB1(outdataB[1]),.DOB2(outdataB[2]),.DOB3(outdataB[3]),.DOB4(outdataB[4]),.DOB5(outdataB[5]),.DOB6(outdataB[6]),.DOB7(outdataB[7]),.DOB8(outdataB[8]),.DOB9(outdataB[9]),.DOB10(outdataB[10]),.DOB11(outdataB[11]),.DOB12(outdataB[12]),.DOB13(outdataB[13]),.DOB14(outdataB[14]),.DOB15(outdataB[15]),.DOB16(outdataB[16]),.DOB17(outdataB[17]),.DOB18(outdataB[18]),.DOB19(outdataB[19]),
                .DIA0(outraminA[0]),.DIA1(outraminA[1]),.DIA2(outraminA[2]),.DIA3(outraminA[3]),.DIA4(outraminA[4]),.DIA5(outraminA[5]),.DIA6(outraminA[6]),.DIA7(outraminA[7]),.DIA8(outraminA[8]),.DIA9(outraminA[9]),.DIA10(outraminA[10]),.DIA11(outraminA[11]),.DIA12(outraminA[12]),.DIA13(outraminA[13]),.DIA14(outraminA[14]),.DIA15(outraminA[15]),.DIA16(outraminA[16]),.DIA17(outraminA[17]),.DIA18(outraminA[18]),.DIA19(outraminA[19]),
                .DIB0(1'b0),.DIB1(1'b0),.DIB2(1'b0),.DIB3(1'b0),.DIB4(1'b0),.DIB5(1'b0),.DIB6(1'b0),.DIB7(1'b0),.DIB8(1'b0),.DIB9(1'b0),.DIB10(1'b0),.DIB11(1'b0),.DIB12(1'b0),.DIB13(1'b0),.DIB14(1'b0),.DIB15(1'b0),.DIB16(1'b0),.DIB17(1'b0),.DIB18(1'b0),.DIB19(1'b0),
                .WEAN(outwebA),.WEBN(1'b1),.CKA(clk),.CKB(clk),.CSA(1'b1),.OEA(1'b1),.CSB(1'b1),.OEB(1'b1));
//matrix size
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        sizereg<=0;
    end
    else begin
        if (in_valid&&inputcnt==0) begin
            sizereg<=matrix_size;
        end
    end
end
always @(*) begin
    kerneloffset=25*kernelidx;
    case (sizereg)
        2'b00:begin
            matrixlength=modereg?16:8;
            matrixsize=64;
        end
        2'b01:begin
            matrixlength=modereg?24:16;
            matrixsize=256;
        end
        2'b10:begin
            matrixlength=modereg?40:32;
            matrixsize=1024;
        end
        default:begin
            matrixlength=0;
            matrixsize=0;
        end
endcase
    imageoffset=matrixsize*imageidx;
end
//INPUTCNT and KERNELCNT
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        inputcnt<=0;
        kernelcnt<=0;
    end
    else begin
        if (in_valid) begin
            inputcnt<=inputcnt+1;
        end
        else inputcnt<=0;
        if (kernelcnt==399) begin
            kernelcnt<=0;
        end
        else if (in_valid) begin
            case (sizereg)
                2'b00:begin
                    if (inputcnt>1023) kernelcnt<=kernelcnt+1;
                    else kernelcnt<=0;
                end 
                2'b01:begin
                    if (inputcnt>4095) kernelcnt<=kernelcnt+1;
                    else kernelcnt<=0;
                end 
                2'b10:begin
                    if (inputcnt>16383) kernelcnt<=kernelcnt+1;
                    else kernelcnt<=0;
                end 
                default:kernelcnt<=0;
            endcase
        end
        else kernelcnt<=0;
        if (clkcnt>=4) begin
            kernelcnt<=kernelcnt+1;
        end
    end
end
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        matrixreg<=0;
    end
    else begin
        if (in_valid) begin
            matrixreg<=matrix;
        end
        else matrixreg<=0;
    end
end
//WEBIMAGE
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        WEBIMAGE<=1'b1;
    end
    else begin
        if (in_valid) begin
            case (sizereg)
                2'b00:begin
                    if (inputcnt>=1024) WEBIMAGE<=1'b1;
                    else WEBIMAGE<=1'b0;
                end
                2'b01:begin
                    if (inputcnt>=4096) WEBIMAGE<=1'b1;
                    else WEBIMAGE<=1'b0;
                end
                2'b10:begin
                    if (inputcnt>=16384) WEBIMAGE<=1'b1;
                    else WEBIMAGE<=1'b0; 
                end
                default:WEBIMAGE<=1'b1;
            endcase
        end
        else begin
            if (in_valid2) WEBIMAGE<=1'b0;
            else WEBIMAGE<=1'b1;
        end
    end
end
//WEBKERNEL
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        WEBKERNEL<=1'b1;
    end
    else begin
        if (in_valid)begin
            case (sizereg)
                2'b00:begin
                    if (inputcnt>=1024) WEBKERNEL<=1'b0;
                    else WEBKERNEL<=1'b1;
                end
                2'b01:begin
                    if (inputcnt>=4096) WEBKERNEL<=1'b0;
                    else WEBKERNEL<=1'b1;
                end
                2'b10:begin
                    if (inputcnt>=16384) WEBKERNEL<=1'b0;
                    else WEBKERNEL<=1'b1; 
                end
                default:WEBKERNEL<=1'b1;
            endcase
        end
        else WEBKERNEL<=1'b1;
    end
end
//IMAGEINDEX and KERNELINDEX
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        imageidx<=0;
        kernelidx<=0;
        idxcnt<=0;
    end
    else begin
        if (in_valid2) begin
            if (idxcnt==0) begin
                imageidx<=matrix_idx;
                idxcnt<=1;
            end
            else kernelidx<=matrix_idx;
        end
        else idxcnt<=0;
    end
end
//MODE
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        modereg<=1'b0;
    end
    else begin
        if (in_valid2&&idxcnt==0) begin
            modereg<=mode;
        end
    end
end
//IMAGEADDR
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        imageaddr<=0;
    end
    else begin
        if (in_valid&&inputcnt<=16383) begin
            imageaddr<=inputcnt;
        end
        else begin 
            if (in_valid2) imageaddr<=16384;
            else if(clkcnt>1&&modereg==1'b0)imageaddr<=imageoffset+rowid*matrixlength+colid;
            else if (clkcnt>4&&modereg==1'b1) begin
                if (rowid<4||colid<4||rowid>=(matrixlength-4)||colid>=(matrixlength-4)) imageaddr<=16384;
                else imageaddr<=imageoffset+(rowid-4)*(matrixlength-8)+colid-4;
            end
        end
    end
end
//KERNELADDR
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        keraddr<=0;
    end
    else begin
        if (in_valid&&kernelcnt<=399) begin
            keraddr<=kernelcnt;
        end
        else if(keraddr==399) keraddr<=0;
        else if (clkcnt>=1 && clkcnt<=29) begin
            keraddr<=kerneloffset+kernelcnt;
        end
        else keraddr<=0;
    end
end
//CLKCNT
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        clkcnt<=0;
    end
    else begin
        if (modereg==1 && sizereg==2 &&clkcnt==25960) clkcnt<=0;
        else if (modereg==1 && sizereg==1 &&clkcnt==8040) clkcnt<=0;
        else if (modereg==1 && sizereg==0 &&clkcnt==2920) clkcnt<=0;
        else if (modereg==0 && sizereg==2 &&clkcnt==5623) clkcnt<=0;
        else if (modereg==0 && sizereg==0 &&clkcnt==175) clkcnt<=0;
        else if(modereg==0 && sizereg==1 &&clkcnt==1095)clkcnt<=0;
        else if (clkcnt>0) clkcnt<=clkcnt+1;
        else if (in_valid2) clkcnt<=1; 
    end
end
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        tmpmaxrowid<=0;
    end
    else begin
        if (movectrl_ns==2'b00 || movectrl_ns==2'b10) begin
            if (cnt7==3'd3) begin
                tmpmaxrowid<=rowid;
            end
        end
    end
end
//ROWID START AT 0
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        rowid<=0;
    end
    else begin
        if (clkcnt>3&&clkcnt<=28) begin
            rowid<=cnt7;
        end
        else if (clkcnt>=30) begin
            if (movectrl_ns==2'b01 || movectrl_ns==2'b11) begin
                rowid<=tmpmaxrowid+1;
            end
            else if (movectrl_ns==2'b00 || movectrl_ns==2'b10) begin
                if (cnt7==3'd5) rowid<=cntset;
                else rowid<=rowid+1;
            end
        end
        else rowid<=0;
    end
end
//COLID START AT 0
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        colid<=0;
    end
    else begin
        if (clkcnt==2) begin
            case (modereg)
                1'b0:colid<=matrixlength-1; 
                1'b1:colid<=0;
            endcase
        end
        else if (clkcnt>3&&clkcnt<=28) begin
            if (cnt7==0) begin
                case (modereg)
                    1'b0:colid<=colid-1; 
                    1'b1:colid<=colid+1; 
                endcase
            end
        end
        else if (clkcnt>=30) begin
            if (movectrl_cs==3'b00) begin
                if (colid==matrixlength-1&&cnt7==3'd5) begin
                colid<=colid;
                end
                else if (cnt7==3'd5) colid<=colid+1; 
            end
            if (movectrl_cs==3'b01) begin
                if (cnt7==3'd5) begin
                    colid<=matrixlength-6;
                end
                else colid<=colid-1;
            end
            if (movectrl_cs==3'b10) begin
                if (colid==0&&cnt7==3'd5) begin
                    colid<=colid;
                end
                else if (cnt7==3'd5) begin
                    colid<=colid-1;
                end
            end
            if (movectrl_cs==3'b11) begin
                if (cnt7==3'd5) begin
                    colid<=5;
                end
                else colid<=colid+1;
            end
        end
    end
end
//cnt7
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        cnt7<=0;
    end
    else begin
        if (clkcnt>2&&clkcnt<=27) begin
            if (cnt7==4) begin
                cnt7<=0;
            end
            else cnt7<=cnt7+1;
        end
        else if (clkcnt>=31) begin
            if (cnt7==6) begin
                cnt7<=0;
            end
            else cnt7<=cnt7+1;
        end
        else cnt7<=0;
    end
end
//CNTITERATION
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        cntiteration<=0;
    end
    else begin
        if (clkcnt>=31) begin
            if (cnt7==5) begin
                cntiteration<=cntiteration+1;
            end
        end
        else cntiteration<=0;
    end
end
//CNTSET
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        cntset<=0;
    end
    else begin
        if (clkcnt>=31) begin
            if ((colid==0 || colid==matrixlength-1)&&cnt7==3'd5) begin
                cntset<=cntset+1;
            end
        end
        else cntset<=0;
    end
end
//MOVECTRL
always @(*) begin
    if (clkcnt>=31) begin
        case (movectrl_cs)
            2'b00:begin
                if ((colid==matrixlength-1)&&cnt7==3'd5) begin
                    movectrl_ns=2'b01;
                end
                else movectrl_ns=2'b00;
            end 
            2'b01:begin
                if (cnt7==3'd5&&rowid==tmpmaxrowid+1) begin
                    movectrl_ns=2'b10;
                end
                else movectrl_ns=2'b01;
            end
            2'b10:begin
                if (colid==0&&cnt7==3'd5) movectrl_ns=2'b11;
                else movectrl_ns=2'b10;
            end
            2'b11:begin
                if (cnt7==3'd5&&rowid==tmpmaxrowid+1) begin
                    movectrl_ns=2'b00;
                end
                else movectrl_ns=2'b11;
            end
        endcase
    end
    else begin
        case (modereg)
            1'b0:movectrl_ns=2'b10;
            1'b1:movectrl_ns=2'b00;
        endcase
    end 
end
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        movectrl_cs<=2'b00;
    end
    else movectrl_cs<=movectrl_ns;
end
//CALCULATE
//KERNELMATRIX
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (integer i =0 ;i<25 ;i=i+1 ) begin
            kernelmatrix[i]<=0;
        end
    end
    else begin
        if (clkcnt>5&&clkcnt<=30&&modereg==1'b0) begin
            kernelmatrix[24]<=kerdata;
            kernelmatrix[23]<=kernelmatrix[24];
            kernelmatrix[22]<=kernelmatrix[23];
            kernelmatrix[21]<=kernelmatrix[22];
            kernelmatrix[20]<=kernelmatrix[21];
            kernelmatrix[19]<=kernelmatrix[20];
            kernelmatrix[18]<=kernelmatrix[19];
            kernelmatrix[17]<=kernelmatrix[18];
            kernelmatrix[16]<=kernelmatrix[17];
            kernelmatrix[15]<=kernelmatrix[16];
            kernelmatrix[14]<=kernelmatrix[15];
            kernelmatrix[13]<=kernelmatrix[14];
            kernelmatrix[12]<=kernelmatrix[13];
            kernelmatrix[11]<=kernelmatrix[12];
            kernelmatrix[10]<=kernelmatrix[11];
            kernelmatrix[9]<=kernelmatrix[10];
            kernelmatrix[8]<=kernelmatrix[9];
            kernelmatrix[7]<=kernelmatrix[8];
            kernelmatrix[6]<=kernelmatrix[7];
            kernelmatrix[5]<=kernelmatrix[6];
            kernelmatrix[4]<=kernelmatrix[5];
            kernelmatrix[3]<=kernelmatrix[4];
            kernelmatrix[2]<=kernelmatrix[3];
            kernelmatrix[1]<=kernelmatrix[2];
            kernelmatrix[0]<=kernelmatrix[1];
        end
        else if (clkcnt>5&&clkcnt<=30&&modereg==1'b1) begin
            kernelmatrix[0]<=kerdata;
            kernelmatrix[1]<=kernelmatrix[0];
            kernelmatrix[2]<=kernelmatrix[1];
            kernelmatrix[3]<=kernelmatrix[2];
            kernelmatrix[4]<=kernelmatrix[3];
            kernelmatrix[5]<=kernelmatrix[4];
            kernelmatrix[6]<=kernelmatrix[5];
            kernelmatrix[7]<=kernelmatrix[6];
            kernelmatrix[8]<=kernelmatrix[7];
            kernelmatrix[9]<=kernelmatrix[8];
            kernelmatrix[10]<=kernelmatrix[9];
            kernelmatrix[11]<=kernelmatrix[10];
            kernelmatrix[12]<=kernelmatrix[11];
            kernelmatrix[13]<=kernelmatrix[12];
            kernelmatrix[14]<=kernelmatrix[13];
            kernelmatrix[15]<=kernelmatrix[14];
            kernelmatrix[16]<=kernelmatrix[15];
            kernelmatrix[17]<=kernelmatrix[16];
            kernelmatrix[18]<=kernelmatrix[17];
            kernelmatrix[19]<=kernelmatrix[18];
            kernelmatrix[20]<=kernelmatrix[19];
            kernelmatrix[21]<=kernelmatrix[20];
            kernelmatrix[22]<=kernelmatrix[21];
            kernelmatrix[23]<=kernelmatrix[22];
            kernelmatrix[24]<=kernelmatrix[23];
        end
    end
end
//CALMATRIX
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (integer i =0 ;i<30 ;i=i+1 ) begin
            calmatrix[i]<=0;
        end
    end
    else begin
        if (clkcnt>5&&clkcnt<=30) begin
            case (modereg)
                1'b0:begin
                    calmatrix[25]<=imagedata;
                    calmatrix[26]<=calmatrix[25];
                    calmatrix[27]<=calmatrix[26];
                    calmatrix[28]<=calmatrix[27];
                    calmatrix[29]<=calmatrix[28];
                    calmatrix[20]<=calmatrix[29];
                    calmatrix[21]<=calmatrix[20];
                    calmatrix[22]<=calmatrix[21];
                    calmatrix[23]<=calmatrix[22];
                    calmatrix[24]<=calmatrix[23];
                    calmatrix[15]<=calmatrix[24];
                    calmatrix[16]<=calmatrix[15];
                    calmatrix[17]<=calmatrix[16];
                    calmatrix[18]<=calmatrix[17];
                    calmatrix[19]<=calmatrix[18];
                    calmatrix[10]<=calmatrix[19];
                    calmatrix[11]<=calmatrix[10];
                    calmatrix[12]<=calmatrix[11];
                    calmatrix[13]<=calmatrix[12];
                    calmatrix[14]<=calmatrix[13];
                    calmatrix[5]<=calmatrix[14];
                    calmatrix[6]<=calmatrix[5];
                    calmatrix[7]<=calmatrix[6];
                    calmatrix[8]<=calmatrix[7];
                    calmatrix[9]<=calmatrix[8];
                end 
                1'b1:begin
                    calmatrix[5]<=imagedata;
                    calmatrix[6]<=calmatrix[5];
                    calmatrix[7]<=calmatrix[6];
                    calmatrix[8]<=calmatrix[7];
                    calmatrix[9]<=calmatrix[8];
                    calmatrix[10]<=calmatrix[9];
                    calmatrix[11]<=calmatrix[10];
                    calmatrix[12]<=calmatrix[11];
                    calmatrix[13]<=calmatrix[12];
                    calmatrix[14]<=calmatrix[13];
                    calmatrix[15]<=calmatrix[14];
                    calmatrix[16]<=calmatrix[15];
                    calmatrix[17]<=calmatrix[16];
                    calmatrix[18]<=calmatrix[17];
                    calmatrix[19]<=calmatrix[18];
                    calmatrix[20]<=calmatrix[19];
                    calmatrix[21]<=calmatrix[20];
                    calmatrix[22]<=calmatrix[21];
                    calmatrix[23]<=calmatrix[22];
                    calmatrix[24]<=calmatrix[23];
                    calmatrix[25]<=calmatrix[24];
                    calmatrix[26]<=calmatrix[25];
                    calmatrix[27]<=calmatrix[26];
                    calmatrix[28]<=calmatrix[27];
                    calmatrix[29]<=calmatrix[28];
                end 
            endcase
        end
        else begin
            case (cnt7)
                3'd1:calmatrix[0]<=imagedata;
                3'd2:calmatrix[1]<=imagedata;
                3'd3:calmatrix[2]<=imagedata;
                3'd4:calmatrix[3]<=imagedata;
                3'd5:calmatrix[4]<=imagedata;
                3'd6:begin
                    case (movectrl_cs)
                        2'b00:begin
                            if (colid==5 && cntiteration>1) begin
                                calmatrix[25]<=calmatrix[0];
                                calmatrix[20]<=calmatrix[1];
                                calmatrix[15]<=calmatrix[2];
                                calmatrix[10]<=calmatrix[3];
                                calmatrix[5]<=calmatrix[4];
                                for (integer i=5 ;i<9 ;i=i+1 ) begin
                                    calmatrix[i+1]<=calmatrix[i];
                                end
                                for (integer i=10 ;i<14 ;i=i+1 ) begin
                                    calmatrix[i+1]<=calmatrix[i];
                                end
                                for (integer i=15 ;i<19 ;i=i+1 ) begin
                                    calmatrix[i+1]<=calmatrix[i];
                                end
                                for (integer i=20 ;i<24 ;i=i+1 ) begin
                                    calmatrix[i+1]<=calmatrix[i];
                                end
                                for (integer i=25 ;i<29 ;i=i+1 ) begin
                                    calmatrix[i+1]<=calmatrix[i];
                                end
                            end
                            else begin
                                calmatrix[9]<=calmatrix[0];
                                calmatrix[8]<=calmatrix[1];
                                calmatrix[7]<=calmatrix[2];
                                calmatrix[6]<=calmatrix[3];
                                calmatrix[5]<=calmatrix[4];
                                for (integer i =5 ;i<25 ;i=i+1 ) begin
                                    calmatrix[i+5]<=calmatrix[i];
                                end
                            end
                        end
                        2'b01:begin
                            if (colid==matrixlength-1) begin
                                calmatrix[9]<=calmatrix[0];
                                calmatrix[8]<=calmatrix[1];
                                calmatrix[7]<=calmatrix[2];
                                calmatrix[6]<=calmatrix[3];
                                calmatrix[5]<=calmatrix[4];
                                for (integer i =5 ;i<25 ;i=i+1 ) begin
                                    calmatrix[i+5]<=calmatrix[i];
                                end
                            end
                        end
                        2'b10:begin
                            if (colid==matrixlength-6) begin
                                for (integer i=5 ;i<9 ;i=i+1 ) begin
                                    calmatrix[i+1]<=calmatrix[i];
                                end
                                for (integer i=10 ;i<14 ;i=i+1 ) begin
                                    calmatrix[i+1]<=calmatrix[i];
                                end
                                for (integer i=15 ;i<19 ;i=i+1 ) begin
                                    calmatrix[i+1]<=calmatrix[i];
                                end
                                for (integer i=20 ;i<24 ;i=i+1 ) begin
                                    calmatrix[i+1]<=calmatrix[i];
                                end
                                for (integer i=25 ;i<29 ;i=i+1 ) begin
                                    calmatrix[i+1]<=calmatrix[i];
                                end
                                calmatrix[5]<=calmatrix[0];
                                calmatrix[10]<=calmatrix[1];
                                calmatrix[15]<=calmatrix[2];
                                calmatrix[20]<=calmatrix[3];
                                calmatrix[25]<=calmatrix[4];
                            end
                            else begin
                                calmatrix[29]<=calmatrix[0];
                                calmatrix[28]<=calmatrix[1];
                                calmatrix[27]<=calmatrix[2];
                                calmatrix[26]<=calmatrix[3];
                                calmatrix[25]<=calmatrix[4];
                                for (integer i =29 ;i>=10 ;i=i-1 ) begin
                                    calmatrix[i-5]<=calmatrix[i];
                                end
                            end
                        end
                        2'b11:begin
                            if (colid==0) begin
                                calmatrix[29]<=calmatrix[0];
                                calmatrix[28]<=calmatrix[1];
                                calmatrix[27]<=calmatrix[2];
                                calmatrix[26]<=calmatrix[3];
                                calmatrix[25]<=calmatrix[4];
                                for (integer i =29 ;i>=10 ;i=i-1 ) begin
                                    calmatrix[i-5]<=calmatrix[i];
                                end
                            end
                        end
                    endcase
                end
            endcase
        end
    end
end
always @(*) begin
    if (clkcnt>=31) begin
        case (cnt7)
            3'd0:begin
                tmp1=calmatrix[29];
                tmp2=kernelmatrix[0];
                tmp3=calmatrix[24];
                tmp4=kernelmatrix[1];
                tmp5=calmatrix[19];
                tmp6=kernelmatrix[2];
                tmp7=calmatrix[14];
                tmp8=kernelmatrix[3];
                tmp9=calmatrix[9];
                tmp10=kernelmatrix[4];
            end
            3'd1:begin
                tmp1=calmatrix[28];
                tmp2=kernelmatrix[5];
                tmp3=calmatrix[23];
                tmp4=kernelmatrix[6];
                tmp5=calmatrix[18];
                tmp6=kernelmatrix[7];
                tmp7=calmatrix[13];
                tmp8=kernelmatrix[8];
                tmp9=calmatrix[8];
                tmp10=kernelmatrix[9];
            end
            3'd2:begin
                tmp1=calmatrix[27];
                tmp2=kernelmatrix[10];
                tmp3=calmatrix[22];
                tmp4=kernelmatrix[11];
                tmp5=calmatrix[17];
                tmp6=kernelmatrix[12];
                tmp7=calmatrix[12];
                tmp8=kernelmatrix[13];
                tmp9=calmatrix[7];
                tmp10=kernelmatrix[14];
            end
            3'd3:begin
                tmp1=calmatrix[26];
                tmp2=kernelmatrix[15];
                tmp3=calmatrix[21];
                tmp4=kernelmatrix[16];
                tmp5=calmatrix[16];
                tmp6=kernelmatrix[17];
                tmp7=calmatrix[11];
                tmp8=kernelmatrix[18];
                tmp9=calmatrix[6];
                tmp10=kernelmatrix[19];
            end
            3'd4:begin
                tmp1=calmatrix[25];
                tmp2=kernelmatrix[20];
                tmp3=calmatrix[20];
                tmp4=kernelmatrix[21];
                tmp5=calmatrix[15];
                tmp6=kernelmatrix[22];
                tmp7=calmatrix[10];
                tmp8=kernelmatrix[23];
                tmp9=calmatrix[5];
                tmp10=kernelmatrix[24];
            end
            default: begin
                tmp1=0;
                tmp2=0;
                tmp3=0;
                tmp4=0;
                tmp5=0;
                tmp6=0;
                tmp7=0;
                tmp8=0;
                tmp9=0;
                tmp10=0;
            end
        endcase
    end
    else begin
        tmp1=0;
        tmp2=0;
        tmp3=0;
        tmp4=0;
        tmp5=0;
        tmp6=0;
        tmp7=0;
        tmp8=0;
        tmp9=0;
        tmp10=0;
    end
end
always @(*) begin
    tmpsum=tmp1*tmp2+tmp3*tmp4+tmp5*tmp6+tmp7*tmp8+tmp9*tmp10;
end
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        sum<=0;
    end
    else begin
        if (clkcnt>=31) begin
            if (cnt7<=4) begin
                sum<=sum+tmpsum;
            end
            else sum<=0;
        end
        else sum<=0;
    end
end
//maxpooling
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        cntmaxpool<=0;
    end
    else begin
        case (modereg)
            1'b0:begin
                case (sizereg)
                    2'b00:begin
                        if (clkcnt>=31) begin
                            if (cntmaxpool==7&&cnt7==3'd6) begin
                                cntmaxpool<=0;
                            end
                            else if (cnt7==3'd6) begin
                                cntmaxpool<=cntmaxpool+1;
                            end
                        end
                        else cntmaxpool<=0;
                    end 
                    2'b01:begin
                        if (clkcnt>=31) begin
                            if (cntmaxpool==23&&cnt7==3'd6) begin
                                cntmaxpool<=0;
                            end
                            else if (cnt7==3'd6) begin
                                cntmaxpool<=cntmaxpool+1;
                            end
                        end
                        else cntmaxpool<=0;
                    end
                    2'b10:begin
                        if (clkcnt>=31) begin
                            if (cntmaxpool==55&&cnt7==3'd6) begin
                                cntmaxpool<=0;
                            end
                            else if (cnt7==3'd6) begin
                                cntmaxpool<=cntmaxpool+1;
                            end
                        end
                        else cntmaxpool<=0;
                    end 
                    default:cntmaxpool<=0;
                endcase
            end 
            1'b1:begin
                case (sizereg)
                    2'b00:begin
                        if (clkcnt>=31) begin
                            if (cntmaxpool==23&&cnt7==3'd6) begin
                                cntmaxpool<=0;
                            end
                            else if (cnt7==3'd6) begin
                                cntmaxpool<=cntmaxpool+1;
                            end
                        end
                        else cntmaxpool<=0;
                    end 
                    2'b01:begin
                        if (clkcnt>=31) begin
                            if (cntmaxpool==39&&cnt7==3'd6) begin
                                cntmaxpool<=0;
                            end
                            else if (cnt7==3'd6) begin
                                cntmaxpool<=cntmaxpool+1;
                            end
                        end
                        else cntmaxpool<=0;
                    end
                    2'b10:begin
                        if (clkcnt>=31) begin
                            if (cntmaxpool==71&&cnt7==3'd6) begin
                                cntmaxpool<=0;
                            end
                            else if (cnt7==3'd6) begin
                                cntmaxpool<=cntmaxpool+1;
                            end
                        end
                        else cntmaxpool<=0;
                    end 
                    default:cntmaxpool<=0;
                endcase
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
        if (clkcnt>=31&&cnt7==3'd5) begin
            case (sizereg)
                2'b00:begin
                    case (cntmaxpool)
                        7'd0: tmpcmp1<=sum;
                        7'd1: tmpcmp2<=sum;
                        7'd2: tmpcmp1<=sum;
                        7'd3: tmpcmp2<=sum;
                        7'd4: begin
                            tmpcmp1<=tmpmax;
                            tmpcmp2<=sum;
                        end
                        7'd5:begin
                            tmpcmp1<=tmpmax;
                            tmpcmp2<=sum;
                        end
                        7'd6:begin
                            tmpcmp1<=maxpoolreg[1];
                            tmpcmp2<=sum;
                        end
                        7'd7:begin
                            tmpcmp1<=tmpmax;
                            tmpcmp2<=sum;
                        end
                    endcase
                end 
                2'b01:begin
                    case (cntmaxpool)
                        7'd0: tmpcmp1<=sum;
                        7'd1: tmpcmp2<=sum;
                        7'd2: tmpcmp1<=sum;
                        7'd3: tmpcmp2<=sum;
                        7'd4: tmpcmp1<=sum;
                        7'd5: tmpcmp2<=sum;
                        7'd6: tmpcmp1<=sum;
                        7'd7: tmpcmp2<=sum;
                        7'd8: tmpcmp1<=sum;
                        7'd9: tmpcmp2<=sum;
                        7'd10: tmpcmp1<=sum;
                        7'd11: tmpcmp2<=sum;
                        7'd12:begin
                            tmpcmp1<=tmpmax;
                            tmpcmp2<=sum;
                        end
                        7'd13:begin
                            tmpcmp1<=tmpmax;
                            tmpcmp2<=sum;
                        end
                        7'd14:begin
                            tmpcmp1<=maxpoolreg[1];
                            tmpcmp2<=sum;
                        end
                        7'd15:begin
                            tmpcmp1<=tmpmax;
                            tmpcmp2<=sum;
                        end
                        7'd16:begin
                            tmpcmp1<=maxpoolreg[2];
                            tmpcmp2<=sum;
                        end
                        7'd17:begin
                            tmpcmp1<=tmpmax;
                            tmpcmp2<=sum;
                        end
                        7'd18:begin
                            tmpcmp1<=maxpoolreg[3];
                            tmpcmp2<=sum;
                        end
                        7'd19:begin
                            tmpcmp1<=tmpmax;
                            tmpcmp2<=sum;
                        end
                        7'd20:begin
                            tmpcmp1<=maxpoolreg[4];
                            tmpcmp2<=sum;
                        end
                        7'd21:begin
                            tmpcmp1<=tmpmax;
                            tmpcmp2<=sum;
                        end
                        7'd22:begin
                            tmpcmp1<=maxpoolreg[5];
                            tmpcmp2<=sum;
                        end
                        7'd23:begin
                            tmpcmp1<=tmpmax;
                            tmpcmp2<=sum;
                        end
                    endcase
                end 
                2'b10:begin
                    case (cntmaxpool)
                        7'd0: tmpcmp1<=sum;
                        7'd1: tmpcmp2<=sum;
                        7'd2: tmpcmp1<=sum;
                        7'd3: tmpcmp2<=sum;
                        7'd4: tmpcmp1<=sum;
                        7'd5: tmpcmp2<=sum;
                        7'd6: tmpcmp1<=sum;
                        7'd7: tmpcmp2<=sum;
                        7'd8: tmpcmp1<=sum;
                        7'd9: tmpcmp2<=sum;
                        7'd10: tmpcmp1<=sum;
                        7'd11: tmpcmp2<=sum;
                        7'd12: tmpcmp1<=sum;
                        7'd13: tmpcmp2<=sum;
                        7'd14: tmpcmp1<=sum;
                        7'd15: tmpcmp2<=sum;
                        7'd16: tmpcmp1<=sum;
                        7'd17: tmpcmp2<=sum;
                        7'd18: tmpcmp1<=sum;
                        7'd19: tmpcmp2<=sum;
                        7'd20: tmpcmp1<=sum;
                        7'd21: tmpcmp2<=sum;
                        7'd22: tmpcmp1<=sum;
                        7'd23: tmpcmp2<=sum;
                        7'd24: tmpcmp1<=sum;
                        7'd25: tmpcmp2<=sum;
                        7'd26: tmpcmp1<=sum;
                        7'd27: tmpcmp2<=sum;
                        7'd28:begin
                            tmpcmp1<=tmpmax;
                            tmpcmp2<=sum;
                        end
                        7'd29:begin
                            tmpcmp1<=tmpmax;
                            tmpcmp2<=sum;
                        end
                        7'd30:begin
                            tmpcmp1<=maxpoolreg[1];
                            tmpcmp2<=sum;
                        end
                        7'd31:begin
                            tmpcmp1<=tmpmax;
                            tmpcmp2<=sum;
                        end
                        7'd32:begin
                            tmpcmp1<=maxpoolreg[2];
                            tmpcmp2<=sum;
                        end
                        7'd33:begin
                            tmpcmp1<=tmpmax;
                            tmpcmp2<=sum;
                        end
                        7'd34:begin
                            tmpcmp1<=maxpoolreg[3];
                            tmpcmp2<=sum;
                        end
                        7'd35:begin
                            tmpcmp1<=tmpmax;
                            tmpcmp2<=sum;
                        end
                        7'd36:begin
                            tmpcmp1<=maxpoolreg[4];
                            tmpcmp2<=sum;
                        end
                        7'd37:begin
                            tmpcmp1<=tmpmax;
                            tmpcmp2<=sum;
                        end
                        7'd38:begin
                            tmpcmp1<=maxpoolreg[5];
                            tmpcmp2<=sum;
                        end
                        7'd39:begin
                            tmpcmp1<=tmpmax;
                            tmpcmp2<=sum;
                        end
                        7'd40:begin
                            tmpcmp1<=maxpoolreg[6];
                            tmpcmp2<=sum;
                        end
                        7'd41:begin
                            tmpcmp1<=tmpmax;
                            tmpcmp2<=sum;
                        end
                        7'd42:begin
                            tmpcmp1<=maxpoolreg[7];
                            tmpcmp2<=sum;
                        end
                        7'd43:begin
                            tmpcmp1<=tmpmax;
                            tmpcmp2<=sum;
                        end
                        7'd44:begin
                            tmpcmp1<=maxpoolreg[8];
                            tmpcmp2<=sum;
                        end
                        7'd45:begin
                            tmpcmp1<=tmpmax;
                            tmpcmp2<=sum;
                        end
                        7'd46:begin
                            tmpcmp1<=maxpoolreg[9];
                            tmpcmp2<=sum;
                        end
                        7'd47:begin
                            tmpcmp1<=tmpmax;
                            tmpcmp2<=sum;
                        end
                        7'd48:begin
                            tmpcmp1<=maxpoolreg[10];
                            tmpcmp2<=sum;
                        end
                        7'd49:begin
                            tmpcmp1<=tmpmax;
                            tmpcmp2<=sum;
                        end
                        7'd50:begin
                            tmpcmp1<=maxpoolreg[11];
                            tmpcmp2<=sum;
                        end
                        7'd51:begin
                            tmpcmp1<=tmpmax;
                            tmpcmp2<=sum;
                        end
                        7'd52:begin
                            tmpcmp1<=maxpoolreg[12];
                            tmpcmp2<=sum;
                        end
                        7'd53:begin
                            tmpcmp1<=tmpmax;
                            tmpcmp2<=sum;
                        end
                        7'd54:begin
                            tmpcmp1<=maxpoolreg[13];
                            tmpcmp2<=sum;
                        end
                        7'd55:begin
                            tmpcmp1<=tmpmax;
                            tmpcmp2<=sum;
                        end
                    endcase
                end
            endcase
        end
    end
end
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (integer i=0 ;i<20 ;i=i+1 ) begin
            maxpoolreg[i]<=0;
        end
    end
    else begin
        if (clkcnt>=31&&cnt7==3'd6) begin
            case (sizereg)
                2'b00:begin
                    case (cntmaxpool)
                        7'd1:maxpoolreg[1]<=tmpmax;
                        7'd5:maxpoolreg[0]<=tmpmax;
                        7'd7:maxpoolreg[1]<=tmpmax;
                    endcase
                end
                2'b01:begin
                    case (cntmaxpool)
                        7'd1:maxpoolreg[5]<=tmpmax;
                        7'd3:maxpoolreg[4]<=tmpmax;
                        7'd5:maxpoolreg[3]<=tmpmax;
                        7'd7:maxpoolreg[2]<=tmpmax;
                        7'd9:maxpoolreg[1]<=tmpmax;
                        7'd13:maxpoolreg[0]<=tmpmax;
                        7'd15:maxpoolreg[1]<=tmpmax;
                        7'd17:maxpoolreg[2]<=tmpmax;
                        7'd19:maxpoolreg[3]<=tmpmax;
                        7'd21:maxpoolreg[4]<=tmpmax;
                        7'd23:maxpoolreg[5]<=tmpmax;
                    endcase
                end
                2'b10:begin
                    case (cntmaxpool)
                        7'd1:maxpoolreg[13]<=tmpmax;
                        7'd3:maxpoolreg[12]<=tmpmax;
                        7'd5:maxpoolreg[11]<=tmpmax;
                        7'd7:maxpoolreg[10]<=tmpmax;
                        7'd9:maxpoolreg[9]<=tmpmax;
                        7'd11:maxpoolreg[8]<=tmpmax;
                        7'd13:maxpoolreg[7]<=tmpmax;
                        7'd15:maxpoolreg[6]<=tmpmax;
                        7'd17:maxpoolreg[5]<=tmpmax;
                        7'd19:maxpoolreg[4]<=tmpmax;
                        7'd21:maxpoolreg[3]<=tmpmax;
                        7'd23:maxpoolreg[2]<=tmpmax;
                        7'd25:maxpoolreg[1]<=tmpmax;
                        7'd29:maxpoolreg[0]<=tmpmax;
                        7'd31:maxpoolreg[1]<=tmpmax;
                        7'd33:maxpoolreg[2]<=tmpmax;
                        7'd35:maxpoolreg[3]<=tmpmax;
                        7'd37:maxpoolreg[4]<=tmpmax;
                        7'd39:maxpoolreg[5]<=tmpmax;
                        7'd41:maxpoolreg[6]<=tmpmax;
                        7'd43:maxpoolreg[7]<=tmpmax;
                        7'd45:maxpoolreg[8]<=tmpmax;
                        7'd47:maxpoolreg[9]<=tmpmax;
                        7'd49:maxpoolreg[10]<=tmpmax;
                        7'd51:maxpoolreg[11]<=tmpmax;
                        7'd53:maxpoolreg[12]<=tmpmax;
                        7'd55:maxpoolreg[13]<=tmpmax;
                    endcase
                end
            endcase
        end
    end
end
always @(*) begin
    tmpmax=tmpcmp1>=tmpcmp2?tmpcmp1:tmpcmp2;
    cntmaxpooltmp=cntmaxpool%2;
end
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        cntmaxpooladdr<=0;
    end
    else begin
        if (clkcnt>=31) begin
            if (cntset>0) begin
                case (sizereg)
                    2'b00:begin
                        if ((cntmaxpool==6||cntmaxpool==0)&&cntmaxpooltmp==0&&cnt7==2) begin
                            cntmaxpooladdr<=cntmaxpooladdr+1;
                        end
                    end
                    2'b01:begin
                        if ((cntmaxpool>=14||cntmaxpool==0)&&cntmaxpooltmp==0&&cnt7==2) begin
                            cntmaxpooladdr<=cntmaxpooladdr+1;
                        end
                    end
                    2'b10:begin
                        if ((cntmaxpool>=30||cntmaxpool==0)&&cntmaxpooltmp==0&&cnt7==2) begin
                            cntmaxpooladdr<=cntmaxpooladdr+1;
                        end
                    end
                    2'b11:cntmaxpooladdr<=0;
                endcase
            end
        end
        else cntmaxpooladdr<=0;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        cntformaxpoolsram<=0;
    end
    else begin
        case (modereg)
            1'b0:begin
                case (sizereg)
                    2'b01:begin
                        if (clkcnt>395) begin
                            if (cnt20==16) begin
                                cntformaxpoolsram<=cntformaxpoolsram+1;
                            end
                        end
                        else cntformaxpoolsram<=1;
                    end
                    2'b10:begin
                        if (clkcnt>1725) begin
                            if (cnt20==16) begin
                                cntformaxpoolsram<=cntformaxpoolsram+1;
                            end
                        end
                        else cntformaxpoolsram<=1;
                    end
                    default:cntformaxpoolsram<=0;
                endcase
            end 
            1'b1:begin
                if (clkcnt>58) begin
                    if (cnt20==16&&clkcnt<=25955) cntformaxpoolsram<=cntformaxpoolsram+1;
                end
                else cntformaxpoolsram<=1;
            end 
        endcase
    end
end
//OUTPUTSRAM CONTROL
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        cntmode1index<=0;
    end
    else begin
        if (clkcnt>=32) begin
            if (cntmaxpool==0&&cntset>0&&cnt7==0) begin
                case (sizereg)
                    2'b00:cntmode1index<=cntmode1index+24;
                    2'b01:cntmode1index<=cntmode1index+40;
                    2'b10:cntmode1index<=cntmode1index+72;
                endcase
            end
        end
        else cntmode1index<=0;
    end
end
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        outaddrA<=0;
    end
    else begin
        if (clkcnt>=31) begin
            case (modereg)
                1'b0:begin
                    if (cntset>0) begin
                        case (sizereg)
                            2'b00:begin
                                if ((cntmaxpool==6||cntmaxpool==0)&&cntmaxpooltmp==0&&cnt7==2) begin
                                    outaddrA<=cntmaxpooladdr;
                                end
                            end
                            2'b01:begin
                                if ((cntmaxpool>=14||cntmaxpool==0)&&cntmaxpooltmp==0&&cnt7==2) begin
                                    outaddrA<=cntmaxpooladdr;
                                end
                            end
                            2'b10:begin
                                if ((cntmaxpool>=30||cntmaxpool==0)&&cntmaxpooltmp==0&&cnt7==2) begin
                                    outaddrA<=cntmaxpooladdr;
                                end
                            end
                            default:outaddrA<=0;
                        endcase
                    end
                end
                1'b1:begin
                    if (outaddrA==1296) begin
                        outaddrA<=0;
                    end
                    else begin
                        case (sizereg)
                            2'b00:begin
                                if (cntmaxpool<=11) begin
                                    outaddrA<=cntmode1index+cntmaxpool;
                                end
                                else begin
                                    case (cntmaxpool)
                                        7'd12:outaddrA<=cntmode1index+23;
                                        7'd13:outaddrA<=cntmode1index+22;
                                        7'd14:outaddrA<=cntmode1index+21;
                                        7'd15:outaddrA<=cntmode1index+20;
                                        7'd16:outaddrA<=cntmode1index+19;
                                        7'd17:outaddrA<=cntmode1index+18;
                                        7'd18:outaddrA<=cntmode1index+17;
                                        7'd19:outaddrA<=cntmode1index+16;
                                        7'd20:outaddrA<=cntmode1index+15;
                                        7'd21:outaddrA<=cntmode1index+14;
                                        7'd22:outaddrA<=cntmode1index+13;
                                        7'd23:outaddrA<=cntmode1index+12;
                                        default:outaddrA<=0;
                                    endcase
                                end
                            end
                            2'b01:begin
                                if (cntmaxpool<=19) begin
                                    outaddrA<=cntmode1index+cntmaxpool;
                                end
                                else begin
                                    case (cntmaxpool)
                                        7'd20:outaddrA<=cntmode1index+39;
                                        7'd21:outaddrA<=cntmode1index+38;
                                        7'd22:outaddrA<=cntmode1index+37;
                                        7'd23:outaddrA<=cntmode1index+36;
                                        7'd24:outaddrA<=cntmode1index+35;
                                        7'd25:outaddrA<=cntmode1index+34;
                                        7'd26:outaddrA<=cntmode1index+33;
                                        7'd27:outaddrA<=cntmode1index+32;
                                        7'd28:outaddrA<=cntmode1index+31;
                                        7'd29:outaddrA<=cntmode1index+30;
                                        7'd30:outaddrA<=cntmode1index+29;
                                        7'd31:outaddrA<=cntmode1index+28;
                                        7'd32:outaddrA<=cntmode1index+27;
                                        7'd33:outaddrA<=cntmode1index+26;
                                        7'd34:outaddrA<=cntmode1index+25;
                                        7'd35:outaddrA<=cntmode1index+24;
                                        7'd36:outaddrA<=cntmode1index+23;
                                        7'd37:outaddrA<=cntmode1index+22;
                                        7'd38:outaddrA<=cntmode1index+21;
                                        7'd39:outaddrA<=cntmode1index+20;
                                        default:outaddrA<=0;
                                    endcase
                                end
                            end
                            2'b10:begin
                                if (clkcnt<=9103) begin
                                    if (cntmaxpool<=35) begin
                                        outaddrA<=cntmode1index+cntmaxpool;
                                    end
                                    else begin
                                        case (cntmaxpool)
                                            7'd36:outaddrA<=cntmode1index+71;
                                            7'd37:outaddrA<=cntmode1index+70;
                                            7'd38:outaddrA<=cntmode1index+69;
                                            7'd39:outaddrA<=cntmode1index+68;
                                            7'd40:outaddrA<=cntmode1index+67;
                                            7'd41:outaddrA<=cntmode1index+66;
                                            7'd42:outaddrA<=cntmode1index+65;
                                            7'd43:outaddrA<=cntmode1index+64;
                                            7'd44:outaddrA<=cntmode1index+63;
                                            7'd45:outaddrA<=cntmode1index+62;
                                            7'd46:outaddrA<=cntmode1index+61;
                                            7'd47:outaddrA<=cntmode1index+60;
                                            7'd48:outaddrA<=cntmode1index+59;
                                            7'd49:outaddrA<=cntmode1index+58;
                                            7'd50:outaddrA<=cntmode1index+57;
                                            7'd51:outaddrA<=cntmode1index+56;
                                            7'd52:outaddrA<=cntmode1index+55;
                                            7'd53:outaddrA<=cntmode1index+54;
                                            7'd54:outaddrA<=cntmode1index+53;
                                            7'd55:outaddrA<=cntmode1index+52;
                                            7'd56:outaddrA<=cntmode1index+51;
                                            7'd57:outaddrA<=cntmode1index+50;
                                            7'd58:outaddrA<=cntmode1index+49;
                                            7'd59:outaddrA<=cntmode1index+48;
                                            7'd60:outaddrA<=cntmode1index+47;
                                            7'd61:outaddrA<=cntmode1index+46;
                                            7'd62:outaddrA<=cntmode1index+45;
                                            7'd63:outaddrA<=cntmode1index+44;
                                            7'd64:outaddrA<=cntmode1index+43;
                                            7'd65:outaddrA<=cntmode1index+42;
                                            7'd66:outaddrA<=cntmode1index+41;
                                            7'd67:outaddrA<=cntmode1index+40;
                                            7'd68:outaddrA<=cntmode1index+39;
                                            7'd69:outaddrA<=cntmode1index+38;
                                            7'd70:outaddrA<=cntmode1index+37;
                                            7'd71:outaddrA<=cntmode1index+36;
                                            default:outaddrA<=0;
                                        endcase
                                    end
                                end
                            end
                        endcase
                    end
                end
            endcase
        end
        else outaddrA<=1;
    end
end
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        outaddrB<=0;
    end
    else begin
        case (modereg)
            1'b0:begin
                case (sizereg)
                    2'b00:begin
                        if (clkcnt==112) outaddrB<=1; 
                        else if(clkcnt==132)outaddrB<=2;
                        else if(clkcnt==152)outaddrB<=3;
                        else if (clkcnt==0)outaddrB<=0;
                    end 
                    2'b01:begin
                        if(clkcnt==392)outaddrB<=1;
                        else if (clkcnt>392)outaddrB<=cntformaxpoolsram;
                        else if (clkcnt==0)outaddrB<=0;
                    end
                    2'b10:begin
                        if(clkcnt==1720)outaddrB<=1;
                        else if (clkcnt>1723)outaddrB<=cntformaxpoolsram;
                        else if (clkcnt==0)outaddrB<=0;
                    end
                endcase
            end
            1'b1:begin
                if (clkcnt==57)outaddrB<=1;
                else if (clkcnt>60) outaddrB<=cntformaxpoolsram;
                else if (clkcnt==0) outaddrB<=0;
            end 
        endcase
    end
end
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        outwebA<=1'b1;
    end
    else begin
        if (clkcnt>=31) begin
            case (modereg)
                1'b0:begin
                    if (cntset>0) begin
                        case (sizereg)
                            2'b00:begin
                                if (clkcnt>147) begin
                                    outwebA<=1'b1;
                                end
                                else if ((cntmaxpool==6||cntmaxpool==0)&&cntmaxpooltmp==0&&cnt7==2) outwebA<=1'b0;
                                else outwebA<=1'b1;
                            end
                            2'b01:begin
                                if (clkcnt>1047) begin
                                    outwebA<=1'b1;
                                end
                                else if ((cntmaxpool>=14||cntmaxpool==0)&&cntmaxpooltmp==0&&cnt7==2) outwebA<=1'b0;
                                else outwebA<=1'b1;
                            end
                            2'b10:begin
                                if (clkcnt>5532) begin
                                    outwebA<=1'b1;
                                end
                                else if ((cntmaxpool>=30||cntmaxpool==0)&&cntmaxpooltmp==0&&cnt7==2) outwebA<=1'b0;
                                else outwebA<=1'b1;
                            end
                            default:outwebA<=1'b1;
                    endcase
                    end
                end
                1'b1:begin
                    if (clkcnt>=31) begin
                        case (sizereg)
                            2'b00:begin
                                if (clkcnt>1037) begin
                                    outwebA<=1'b1;
                                end
                                else if (cnt7==5) outwebA<=1'b0;
                                else outwebA<=1'b1;
                            end 
                            2'b01:begin
                                if (clkcnt>2837) begin
                                    outwebA<=1'b1;
                                end
                                else if (cnt7==5) outwebA<=1'b0;
                                else outwebA<=1'b1;
                            end 
                            2'b10:begin
                                if (clkcnt>9103) begin
                                    outwebA<=1'b1;
                                end
                                else if (cnt7==5) outwebA<=1'b0;
                                else outwebA<=1'b1;
                            end
                    endcase
                    end
                end 
            endcase
        end
        else outwebA<=1'b1;
    end
end
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        outraminA<=0;
    end
    else begin
        if (in_valid) begin
            outraminA<=0;
        end
        else if (clkcnt>=31) begin
            case (modereg)
                1'b0:begin
                    if (cntset>0) begin
                        if (cnt7==1) begin
                            case (sizereg)
                                2'b00:begin
                                    case (cntmaxpool)
                                        7'd6:outraminA<=maxpoolreg[0]; 
                                        7'd0:outraminA<=maxpoolreg[1];
                                        default:outraminA<=0;
                                    endcase
                                end
                                2'b01:begin
                                    case (cntmaxpool)
                                        7'd14:outraminA<=maxpoolreg[0]; 
                                        7'd16:outraminA<=maxpoolreg[1];
                                        7'd18:outraminA<=maxpoolreg[2]; 
                                        7'd20:outraminA<=maxpoolreg[3];
                                        7'd22:outraminA<=maxpoolreg[4]; 
                                        7'd0:outraminA<=maxpoolreg[5];
                                        default:outraminA<=0;
                                    endcase
                                end
                                2'b10:begin
                                    case (cntmaxpool)
                                        7'd30:outraminA<=maxpoolreg[0]; 
                                        7'd32:outraminA<=maxpoolreg[1];
                                        7'd34:outraminA<=maxpoolreg[2]; 
                                        7'd36:outraminA<=maxpoolreg[3];
                                        7'd38:outraminA<=maxpoolreg[4]; 
                                        7'd40:outraminA<=maxpoolreg[5];
                                        7'd42:outraminA<=maxpoolreg[6]; 
                                        7'd44:outraminA<=maxpoolreg[7];
                                        7'd46:outraminA<=maxpoolreg[8]; 
                                        7'd48:outraminA<=maxpoolreg[9];
                                        7'd50:outraminA<=maxpoolreg[10]; 
                                        7'd52:outraminA<=maxpoolreg[11];
                                        7'd54:outraminA<=maxpoolreg[12]; 
                                        7'd0:outraminA<=maxpoolreg[13];
                                        default:outraminA<=0;
                                    endcase
                                end
                                default:outraminA<=0;
                            endcase
                        end
                    end
                end
                1'b1:outraminA<=sum;
            endcase
        end
    end
end

always @(posedge clk or negedge rst_n)begin
    if (!rst_n) begin
        out_data<=0;
    end
    else out_data<=outdataB;
end
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        cnt20<=0;
    end
    else begin
        case (modereg)
            1'b0:begin
                case (sizereg)
                    2'b00:begin
                        if (clkcnt>94) begin
                            if (cnt20==19) begin
                                cnt20<=0;
                            end
                            else cnt20<=cnt20+1;
                        end
                        else cnt20<=0;
                    end 
                    2'b01:begin
                        if (clkcnt>374) begin
                            if (cnt20==19) begin
                                cnt20<=0;
                            end
                            else cnt20<=cnt20+1;
                        end
                        else cnt20<=0;
                    end
                    2'b10:begin
                        if (clkcnt>1702) begin
                            if (cnt20==19) begin
                                cnt20<=0;
                            end
                            else cnt20<=cnt20+1;
                        end
                        else cnt20<=0;
                    end
                endcase
            end
            1'b1:begin
                if (clkcnt>39) begin
                    if (cnt20==19) begin
                        cnt20<=0;
                    end
                    else cnt20<=cnt20+1;
                end
                else cnt20<=0;
            end 
        endcase
    end
end

//out_valid
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        out_valid<=1'b0;
    end
    else begin
        case (modereg)
            1'b0:begin
                case (sizereg)
                    2'b00:begin
                        if(clkcnt==95)out_valid<=1'b1;
                        else if (clkcnt==175)out_valid<=1'b0;
                    end
                    2'b01:begin
                        if (clkcnt==375) out_valid<=1'b1;
                        else if (clkcnt==1095)out_valid<=1'b0; 
                    end
                    2'b10:begin
                        if (clkcnt==1703) out_valid<=1'b1;
                        else if (clkcnt==5623)out_valid<=1'b0; 
                    end
                endcase
            end 
            1'b1:begin
                case (sizereg)
                    2'b00:begin
                        if(clkcnt==40)out_valid<=1'b1;
                        else if(clkcnt==2920)out_valid<=1'b0;
                    end 
                    2'b01:begin
                        if(clkcnt==40)out_valid<=1'b1;
                        else if(clkcnt==8040)out_valid<=1'b0;
                    end
                    2'b10:begin
                        if(clkcnt==40)out_valid<=1'b1;
                        else if(clkcnt==25960)out_valid<=1'b0;
                    end
                endcase
            end
        endcase
    end
end
//out_value
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        out_value<=0;
    end
    else begin
        case (modereg)
            1'b0:begin
                case (sizereg)
                    2'b00:begin
                        if (clkcnt>=95&&clkcnt<175) begin
                            out_value<=out_data[cnt20];
                        end
                        else out_value<=0;
                    end
                    2'b01:begin
                        if (clkcnt>=375&&clkcnt<1095) begin
                            out_value<=out_data[cnt20];
                        end
                        else out_value<=0;
                    end
                    2'b10:begin
                        if (clkcnt>=1703&&clkcnt<5623) begin
                            out_value<=out_data[cnt20];
                        end
                        else out_value<=0;
                    end
                endcase
            end
            1'b1:begin
                case (sizereg)
                    2'b00:begin
                        if (clkcnt>=40&&clkcnt<2920) begin
                            out_value<=out_data[cnt20];
                        end
                        else out_value<=0;
                    end 
                    2'b01:begin
                        if (clkcnt>=40&&clkcnt<8040) begin
                            out_value<=out_data[cnt20];
                        end
                        else out_value<=0;
                    end
                    2'b10:begin
                        if (clkcnt>=40&&clkcnt<25960) begin
                            out_value<=out_data[cnt20];
                        end
                        else out_value<=0;
                    end
                endcase
            end
        endcase
    end
end

endmodule
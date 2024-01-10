//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   (C) Copyright Si2 LAB @NYCU ED430
//   All Right Reserved
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   ICLAB 2023 Fall
//   Midterm Proejct            : MRA  
//   Author                     : Lin-Hung, Lai
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   File Name   : MRA.v
//   Module Name : MRA
//   Release version : V2.0 (Release Date: 2023-10)
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################

module MRA(
	// CHIP IO
	clk            	,	
	rst_n          	,	
	in_valid       	,	
	frame_id        ,	
	net_id         	,	  
	loc_x          	,	  
    loc_y         	,
	cost	 		,		
	busy         	,

    // AXI4 IO
	     arid_m_inf,
	   araddr_m_inf,
	    arlen_m_inf,
	   arsize_m_inf,
	  arburst_m_inf,
	  arvalid_m_inf,
	  arready_m_inf,
	
	      rid_m_inf,
	    rdata_m_inf,
	    rresp_m_inf,
	    rlast_m_inf,
	   rvalid_m_inf,
	   rready_m_inf,
	
	     awid_m_inf,
	   awaddr_m_inf,
	   awsize_m_inf,
	  awburst_m_inf,
	    awlen_m_inf,
	  awvalid_m_inf,
	  awready_m_inf,
	
	    wdata_m_inf,
	    wlast_m_inf,
	   wvalid_m_inf,
	   wready_m_inf,
	
	      bid_m_inf,
	    bresp_m_inf,
	   bvalid_m_inf,
	   bready_m_inf 
);

// ===============================================================
//  					Input / Output 
// ===============================================================

// << CHIP io port with system >>
input 			  	clk,rst_n;
input 			   	in_valid;
input  [4:0] 		frame_id;
input  [3:0]       	net_id;     
input  [5:0]       	loc_x; 
input  [5:0]       	loc_y; 
output reg [13:0] 	cost;
output reg          busy;       
  
// AXI Interface wire connecttion for pseudo DRAM read/write
/* Hint:
       Your AXI-4 interface could be designed as a bridge in submodule,
	   therefore I declared output of AXI as wire.  
	   Ex: AXI4_interface AXI4_INF(...);
*/
parameter ID_WIDTH=4, DATA_WIDTH=128, ADDR_WIDTH=32;
// ------------------------
// <<<<< AXI READ >>>>>
// ------------------------
// (1)	axi read address channel 
output wire [ID_WIDTH-1:0]      arid_m_inf;
output wire [1:0]            arburst_m_inf;
output wire [2:0]             arsize_m_inf;
output wire [7:0]              arlen_m_inf;
output wire                  arvalid_m_inf;
input  wire                  arready_m_inf;
output wire [ADDR_WIDTH-1:0]  araddr_m_inf;
// ------------------------
// (2)	axi read data channel 
input  wire [ID_WIDTH-1:0]       rid_m_inf;
input  wire                   rvalid_m_inf;
output wire                   rready_m_inf;
input  wire [DATA_WIDTH-1:0]   rdata_m_inf;
input  wire                    rlast_m_inf;
input  wire [1:0]              rresp_m_inf;
// ------------------------
// <<<<< AXI WRITE >>>>>
// ------------------------
// (1) 	axi write address channel 
output wire [ID_WIDTH-1:0]      awid_m_inf;
output wire [1:0]            awburst_m_inf;
output wire [2:0]             awsize_m_inf;
output wire [7:0]              awlen_m_inf;
output wire                  awvalid_m_inf;
input  wire                  awready_m_inf;
output wire [ADDR_WIDTH-1:0]  awaddr_m_inf;
// -------------------------
// (2)	axi write data channel 
output wire                   wvalid_m_inf;
input  wire                   wready_m_inf;
output wire [DATA_WIDTH-1:0]   wdata_m_inf;
output wire                    wlast_m_inf;
// -------------------------
// (3)	axi write response channel 
input  wire  [ID_WIDTH-1:0]      bid_m_inf;
input  wire                   bvalid_m_inf;
output wire                   bready_m_inf;
input  wire  [1:0]             bresp_m_inf;
// -----------------------------


// ===============================================================
//  					Register and Parameter
// ===============================================================
//FSM PARAMETER AND STATE REG
parameter idle=0;
parameter readdram=1;//remember to modify dramreadmodule
parameter initialmap=2;
parameter filled=3;
parameter retrace=4;
parameter resetmap=5;
parameter writedram=6;//remember to modify dramwritemodule
reg idleflag;
reg initialmapflag;
reg readdramflag;
reg filledflag;
reg retraceflag;
reg resetmapflag;
reg writedramflag;
reg [2:0]state,nextstate;
//INPUT CNT AND REGISTER
reg [4:0]frameidreg;
reg [5:0]source_x[0:14];//64*64
reg [5:0]source_y[0:14];
reg [3:0]netidreg[0:14];
reg [5:0]sink_x[0:14];
reg [5:0]sink_y[0:14];
reg cnt2;//count for source and sink (x,y);
reg [3:0]cntfornet;
//SRAM REG
reg [6:0]locmapaddr;
reg [127:0]locmapin;
reg [127:0]locmapout;
reg locmapweb;
reg [6:0]weimapaddr;
reg [127:0]weimapin;
reg [127:0]weimapout;
reg [127:0]sramout;
reg weimapweb;
reg weightreadflag;
reg weightsramdone;
reg [6:0]cntforsramaddr;
reg [6:0]cntforsramaddrp1;//cnt for read data from dram to sram
//MAP REGISTER AND PARAMETER
parameter empty=0;
parameter macro=1;
parameter one=2;
parameter two=3;
reg [5:0]offset;
reg [1:0]map[0:63][0:63];//MAP FLIPFLOP
reg [1:0]cnt4;//use for filled
reg [5:0]retrace_x,retrace_y;
reg blocksink,blocksink1,blocksink2,blocksink3;
reg cntforretrace;
//DRAM REG
reg [127:0]dram_read_in,dram_read_out;
//OUTPUT REG
reg [5:0]waittrueweight;
reg [5:0]trueweight;
reg [3:0]weight;
reg [13:0]totalcost; 
// ===============================================================
//  					     INPUT
// ===============================================================
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) frameidreg<=0;
	else begin
		if(in_valid)frameidreg<=frame_id;
	end
end

always @(posedge clk or negedge rst_n) begin
	if (!rst_n) cnt2<=0;
	else begin
		if (in_valid) begin
			if(cnt2)cnt2<=0;
			else cnt2<=1;
		end
		else cnt2<=0;
	end
end

always @(posedge clk or negedge rst_n) begin
	if(!rst_n) cntfornet<=0;
	else begin
		if (in_valid) begin
			if (cnt2) cntfornet<=cntfornet+1;
		end
		else cntfornet<=0; 
	end
end

always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		for (integer i=0 ;i<15 ;i=i+1 ) begin
			source_x[i]<=0;
			source_y[i]<=0;
		end
	end
	else begin
		if (in_valid&&cnt2==0) begin
			source_x[cntfornet]<=loc_x;
			source_y[cntfornet]<=loc_y;
		end
		if (resetmapflag) begin
			source_x[14]<=0;
			source_y[14]<=0;
			for (integer i=0 ;i<14 ;i=i+1 ) begin
				source_x[i]<=source_x[i+1];
				source_y[i]<=source_y[i+1];
			end
		end
	end
end

always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		for (integer i=0 ;i<15 ;i=i+1 ) begin
			sink_x[i]<=0;
			sink_y[i]<=0;
		end
	end
	else begin
		if (in_valid&&cnt2) begin
			sink_x[cntfornet]<=loc_x;
			sink_y[cntfornet]<=loc_y;
		end
		if (resetmapflag) begin
			sink_x[14]<=0;
			sink_y[14]<=0;
			for (integer i=0 ;i<14 ;i=i+1 ) begin
				sink_x[i]<=sink_x[i+1];
				sink_y[i]<=sink_y[i+1];
			end
		end
	end
end

always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		for (integer i=0 ;i<15 ;i=i+1 ) begin
			netidreg[i]<=0;
		end
	end
	else begin
		if (in_valid) begin
			netidreg[cntfornet]<=net_id;
		end
		if (resetmapflag) begin
			netidreg[14]<=0;
			for (integer i=0 ;i<14 ;i=i+1 ) begin
				netidreg[i]<=netidreg[i+1];
			end
		end
	end
end

// ===============================================================
//  					   SRAM CTRL
// ===============================================================
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) weightreadflag<=0;
	else begin
		if (readdramflag&&nextstate==initialmap) weightreadflag<=1'b1;
		else if(idleflag)weightreadflag<=0;
	end
end

always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		weightsramdone<=0;
	end
	else begin 
		if (rlast_m_inf&&~readdramflag) weightsramdone<=1'b1;
		else if (idleflag ) weightsramdone<=1'b0;
	end
end

always @(posedge clk or negedge rst_n) begin
	if (!rst_n) cntforsramaddr<=0;
	else begin
		if (rvalid_m_inf&&readdramflag) begin
			if (cntforsramaddr==127) cntforsramaddr<=0;
			else cntforsramaddr<=cntforsramaddr+1;
		end
		else if (weightreadflag&&rvalid_m_inf) begin
			if (cntforsramaddr==127) cntforsramaddr<=0;
			else cntforsramaddr<=cntforsramaddr+1; 
		end
		else if (writedramflag&&wready_m_inf) begin
			if (cntforsramaddr==127) cntforsramaddr<=0;
			else cntforsramaddr<=cntforsramaddr+1; 
		end
		else cntforsramaddr<=0;
	end
end

always @(*) begin
	cntforsramaddrp1=cntforsramaddr+1;
end

always @(*) begin
	if (readdramflag) locmapaddr=cntforsramaddr;
	else if (retraceflag) locmapaddr={retrace_y,retrace_x[5]};
	else if (writedramflag&&wready_m_inf) locmapaddr=cntforsramaddrp1;
	else locmapaddr=0;
end

always @(*) begin
	if (readdramflag) locmapweb=1'b0;
	else if(blocksink1&&retraceflag&&~cntforretrace)locmapweb=1'b1;
	else if(blocksink1&&retraceflag&&cntforretrace)locmapweb=1'b0;
	else locmapweb=1'b1;
end

always @(*) begin
	if (readdramflag) locmapin=rdata_m_inf;
	else begin
		for (integer i=0 ;i<32 ;i=i+1 ) begin
			if (retrace_x[4:0]==i) locmapin[i*4 +: 4]=netidreg[0];
			else locmapin[i*4 +: 4]=locmapout[i*4+:4];
		end
	end
end

always @(*) begin
	if (weightreadflag&&!weightsramdone) weimapaddr=cntforsramaddr;
	else weimapaddr={retrace_y,retrace_x[5]};
end

always @(*) begin
	if (weightreadflag&&!weightsramdone) weimapweb=1'b0;
	else weimapweb=1'b1;
end

always @(*) begin
	if (weightreadflag&&!weightsramdone) weimapin=rdata_m_inf;
	else weimapin=0;
end

always @(posedge clk or negedge rst_n) begin
	if (!rst_n) sramout<=0;
	else sramout<=weimapout;
end

always @(*) begin
	dram_read_in=locmapout;
end

// ===============================================================
//  					 FSM AND STATE FLAG
// ===============================================================
always @(posedge clk or negedge rst_n) begin
	if(!rst_n)state<=idle;
	else state<=nextstate;
end

always @(*) begin
	case (state)
		idle:begin
			if (in_valid) nextstate=readdram;
			else nextstate=idle;
		end
		readdram:begin
			if (rlast_m_inf) nextstate=initialmap;
			else nextstate=readdram;
		end 
		initialmap:begin
			nextstate=filled;
		end
		filled:begin
			if (map[sink_y[0]][sink_x[0]][1]) nextstate=retrace;
			else nextstate=filled;
		end
		retrace:begin
			if (retrace_x==source_x[0]&&retrace_y==source_y[0]) begin
				if (netidreg[1]==0) nextstate=writedram;
				else nextstate=resetmap;
			end
			else nextstate=retrace;
		end
		resetmap:begin
			nextstate=initialmap;
		end
		writedram:begin
			if (wlast_m_inf) nextstate=idle;
			else nextstate=writedram;
		end
		default:nextstate=idle;
	endcase
end

always @(*) begin
	idleflag=state==idle;
	readdramflag=state==readdram;
	initialmapflag=state==initialmap;
	filledflag=state==filled;
	retraceflag=state==retrace;
	resetmapflag=state==resetmap;
	writedramflag=state==writedram;
end

// ===============================================================
//  					  MAP CONPUTE
// ===============================================================
always @(*) begin
	offset=cntforsramaddr[0]?6'd32:6'd0;
end

always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		for (integer i=0 ;i<64 ;i=i+1 ) begin
			for (integer j=0 ;j<64 ;j=j+1 ) begin
				map[i][j]<=0;
			end
		end
	end
	else begin
		case (state)
			readdram:begin
				for (integer i=0 ;i<32 ;i=i+1 ) begin
					map[cntforsramaddr[6:1]][offset+i]<=rdata_m_inf[((i+1)*4-1)-:4]?macro:empty;
				end
			end
			initialmap:begin
				map[sink_y[0]][sink_x[0]]<=empty;
				map[source_y[0]][source_x[0]]<=one;
			end
			filled:begin
				for (integer i=0 ;i<64 ;i=i+1 ) begin
					for (integer j=0 ;j<64 ;j=j+1 ) begin
						if (i==0&&j==0)begin 
							if(map[i][j]==empty&&(map[i][1][1]|map[1][j][1])) map[i][j]<={1'b1,cnt4[1]};
						end
						else if (i==0&&(j>=1&&j<=62))begin
							if(map[i][j]==empty&&(map[i][j-1][1]|map[i][j+1][1]|map[1][j][1])) map[i][j]<={1'b1,cnt4[1]};
						end	
						else if (i==0&&j==63)begin
							if(map[i][j]==empty&&(map[i][62][1]|map[1][j][1])) map[i][j]<={1'b1,cnt4[1]};
						end
						else if(i==63&&j==0) begin 
							if(map[i][j]==empty&&(map[62][j][1]|map[i][1][1])) map[i][j]<={1'b1,cnt4[1]};
						end	
						else if(i==63&&j==63) begin
							if(map[i][j]==empty&&(map[62][j][1]|map[i][62][1])) map[i][j]<={1'b1,cnt4[1]};
						end	
						else if (i==63&&(j>=1&&j<=62))begin
							if(map[i][j]==empty&&(map[i][j-1][1]|map[i][j+1][1]|map[62][j][1])) map[i][j]<={1'b1,cnt4[1]};
						end
						else if (j==0&&(i>=1&&i<=62))begin 
							if(map[i][j]==empty&&(map[i+1][j][1]|map[i-1][j][1]|map[i][1][1])) map[i][j]<={1'b1,cnt4[1]};
						end
						else if (j==63&&(i>=1&&i<=62))begin
							if(map[i][j]==empty&&(map[i+1][j][1]|map[i-1][j][1]|map[i][62][1])) map[i][j]<={1'b1,cnt4[1]};
						end
						else begin
							if (map[i][j]==empty&&(map[i+1][j][1]|map[i-1][j][1]|map[i][j+1][1]|map[i][j-1][1])) map[i][j]<={1'b1,cnt4[1]};
						end
					end
				end
			end
			retrace:begin
				if (weightsramdone&&retraceflag) begin
					map[retrace_y][retrace_x]<=macro;
				end
			end
			resetmap:begin
				for (integer i=0 ;i<64 ;i=i+1 ) begin
					for (integer j=0 ;j<64;j=j+1) begin
						map[i][j]<={1'b0,{map[i][j][0]&(!map[i][j][1])}};
					end
				end
			end
		endcase
	end
end

always @(posedge clk or negedge rst_n) begin
	if (!rst_n) cnt4<=0;
	else begin
		if (initialmapflag) cnt4<=1;
		else if (filledflag&&nextstate==filled) begin
			cnt4<=cnt4+1;
		end
		else if ((retraceflag&&weightsramdone&&!cntforretrace)||(filledflag&&nextstate==retrace)) begin
			cnt4<=cnt4-1;
		end
	end
end

always @(posedge clk or negedge rst_n) begin
	if(!rst_n)begin
		blocksink<=0;
		blocksink1<=0;
		blocksink2<=0;
		blocksink3<=0;
	end
	else begin
		blocksink<=weightsramdone&&retraceflag;
		blocksink1<=blocksink;
		blocksink2<=blocksink1;
		blocksink3<=blocksink2;
	end
end

// ===============================================================
//  					   RETRACE MAP
// ===============================================================
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) cntforretrace<=0;
	else begin
		if (retraceflag&&weightsramdone) begin
			if (cntforretrace) cntforretrace<=0;
			else cntforretrace<=1; 
		end
		else cntforretrace<=0;
	end
end

always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		retrace_x<=0;
		retrace_y<=0;
	end
	else begin
		if (blocksink) begin
			if (cntforretrace) begin
				if(retrace_y!=63&&map[retrace_y+1][retrace_x][1]&&map[retrace_y+1][retrace_x][0]==cnt4[1]) begin
					retrace_x<=retrace_x;
					retrace_y<=retrace_y+1;
				end	
				else if(retrace_y!=0&&map[retrace_y-1][retrace_x][1]&&map[retrace_y-1][retrace_x][0]==cnt4[1])begin
					retrace_x<=retrace_x;
					retrace_y<=retrace_y-1;
				end
				else if(retrace_x!=63&&map[retrace_y][retrace_x+1][1]&&map[retrace_y][retrace_x+1][0]==cnt4[1])begin
					retrace_x<=retrace_x+1;
					retrace_y<=retrace_y;
				end
				else begin
					retrace_x<=retrace_x-1;
					retrace_y<=retrace_y;
				end
			end
		end
		else if (retraceflag) begin
			retrace_x<=sink_x[0];
			retrace_y<=sink_y[0];
		end
		else begin
			retrace_x<=0;
			retrace_y<=0;
		end
	end
end

// ===============================================================
//  					    OUTPUT
// ===============================================================
always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		busy<=1'b0;
	end
	else begin
		if(wlast_m_inf) begin
			busy<=1'b0;
		end
		else if(!in_valid&&!idleflag) begin
			busy<=1'b1;
		end
	end
end

always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		cost<=0;
	end
	else begin
		cost<=totalcost;
	end
end

always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		waittrueweight<=0;
		trueweight<=0;
	end
	else begin
		waittrueweight<=retrace_x;
		trueweight<=waittrueweight;
	end
end

always @(*) begin
	weight=sramout[trueweight[4:0]*4 +: 4];
end

always @(posedge clk or negedge rst_n) begin
	if (!rst_n) totalcost<=0;
	else if (blocksink3&&cntforretrace&&blocksink) totalcost<=totalcost+weight;
	else if (idleflag) totalcost<=0;
end

// ===============================================================
//  				   DRAM AND SRAM MODULE
// ===============================================================
DRAM_READ READ(
	.clk(clk),.rst_n(rst_n),.readdramflag(readdramflag),.frameid(frameidreg),.weightreadflag(weightreadflag) ,.weightsramdone(weightsramdone),.dram_read_out(dram_read_out),
	.arid_m_inf(arid_m_inf),.arburst_m_inf(arburst_m_inf), .arsize_m_inf(arsize_m_inf), .arlen_m_inf(arlen_m_inf), 
	.arvalid_m_inf(arvalid_m_inf), .arready_m_inf(arready_m_inf), .araddr_m_inf(araddr_m_inf),
	.rid_m_inf(rid_m_inf),.rvalid_m_inf(rvalid_m_inf), .rready_m_inf(rready_m_inf), .rdata_m_inf(rdata_m_inf),.rlast_m_inf(rlast_m_inf), .rresp_m_inf(rresp_m_inf)
);
DRAM_WRITE WRITE(
	.clk(clk),.rst_n(rst_n),.writedramflag(writedramflag), .dram_read_in(dram_read_in), .frameid(frameidreg),
	.awid_m_inf(awid_m_inf),.awburst_m_inf(awburst_m_inf), .awsize_m_inf(awsize_m_inf), .awlen_m_inf(awlen_m_inf),.awvalid_m_inf(awvalid_m_inf), .awready_m_inf(awready_m_inf), .awaddr_m_inf(awaddr_m_inf),
   	.wvalid_m_inf(wvalid_m_inf), .wready_m_inf(wready_m_inf),.wdata_m_inf(wdata_m_inf), .wlast_m_inf(wlast_m_inf),
    .bid_m_inf(bid_m_inf),.bvalid_m_inf(bvalid_m_inf), .bready_m_inf(bready_m_inf), .bresp_m_inf(bresp_m_inf)
);
MEM locationmap(.A0(locmapaddr[0]),.A1(locmapaddr[1]),.A2(locmapaddr[2]),.A3(locmapaddr[3]),.A4(locmapaddr[4]),.A5(locmapaddr[5]),.A6(locmapaddr[6]),
			.DO0(locmapout[0]),.DO1(locmapout[1]),.DO2(locmapout[2]),.DO3(locmapout[3]),.DO4(locmapout[4]),.DO5(locmapout[5]),.DO6(locmapout[6]),
            .DO7(locmapout[7]),.DO8(locmapout[8]),.DO9(locmapout[9]),.DO10(locmapout[10]),.DO11(locmapout[11]),.DO12(locmapout[12]),.DO13(locmapout[13]),.DO14(locmapout[14]),.DO15(locmapout[15]),
            .DO16(locmapout[16]),.DO17(locmapout[17]),.DO18(locmapout[18]),.DO19(locmapout[19]),.DO20(locmapout[20]),.DO21(locmapout[21]),.DO22(locmapout[22]),.DO23(locmapout[23]),
            .DO24(locmapout[24]),.DO25(locmapout[25]),.DO26(locmapout[26]),.DO27(locmapout[27]),.DO28(locmapout[28]),.DO29(locmapout[29]),.DO30(locmapout[30]),.DO31(locmapout[31]),
            .DO32(locmapout[32]),.DO33(locmapout[33]),.DO34(locmapout[34]),.DO35(locmapout[35]),.DO36(locmapout[36]),.DO37(locmapout[37]),.DO38(locmapout[38]),.DO39(locmapout[39]),
            .DO40(locmapout[40]),.DO41(locmapout[41]),.DO42(locmapout[42]),.DO43(locmapout[43]),.DO44(locmapout[44]),.DO45(locmapout[45]),.DO46(locmapout[46]),.DO47(locmapout[47]),
            .DO48(locmapout[48]),.DO49(locmapout[49]),.DO50(locmapout[50]),.DO51(locmapout[51]),.DO52(locmapout[52]),.DO53(locmapout[53]),.DO54(locmapout[54]),.DO55(locmapout[55]),
            .DO56(locmapout[56]),.DO57(locmapout[57]),.DO58(locmapout[58]),.DO59(locmapout[59]),.DO60(locmapout[60]),.DO61(locmapout[61]),.DO62(locmapout[62]),.DO63(locmapout[63]),
            .DO64(locmapout[64]),.DO65(locmapout[65]),.DO66(locmapout[66]),.DO67(locmapout[67]),.DO68(locmapout[68]),.DO69(locmapout[69]),.DO70(locmapout[70]),.DO71(locmapout[71]),
            .DO72(locmapout[72]),.DO73(locmapout[73]),.DO74(locmapout[74]),.DO75(locmapout[75]),.DO76(locmapout[76]),.DO77(locmapout[77]),.DO78(locmapout[78]),.DO79(locmapout[79]),
            .DO80(locmapout[80]),.DO81(locmapout[81]),.DO82(locmapout[82]),.DO83(locmapout[83]),.DO84(locmapout[84]),.DO85(locmapout[85]),.DO86(locmapout[86]),.DO87(locmapout[87]),
            .DO88(locmapout[88]),.DO89(locmapout[89]),.DO90(locmapout[90]),.DO91(locmapout[91]),.DO92(locmapout[92]),.DO93(locmapout[93]),.DO94(locmapout[94]),.DO95(locmapout[95]),
            .DO96(locmapout[96]),.DO97(locmapout[97]),.DO98(locmapout[98]),.DO99(locmapout[99]),.DO100(locmapout[100]),.DO101(locmapout[101]),.DO102(locmapout[102]),.DO103(locmapout[103]),
            .DO104(locmapout[104]),.DO105(locmapout[105]),.DO106(locmapout[106]),.DO107(locmapout[107]),.DO108(locmapout[108]),.DO109(locmapout[109]),.DO110(locmapout[110]),
            .DO111(locmapout[111]),.DO112(locmapout[112]),.DO113(locmapout[113]),.DO114(locmapout[114]),.DO115(locmapout[115]),.DO116(locmapout[116]),.DO117(locmapout[117]),
            .DO118(locmapout[118]),.DO119(locmapout[119]),.DO120(locmapout[120]),.DO121(locmapout[121]),.DO122(locmapout[122]),.DO123(locmapout[123]),.DO124(locmapout[124]),.DO125(locmapout[125]),.DO126(locmapout[126]),.DO127(locmapout[127]),
			.DI0(locmapin[0]),.DI1(locmapin[1]),.DI2(locmapin[2]),.DI3(locmapin[3]),.DI4(locmapin[4]),.DI5(locmapin[5]),.DI6(locmapin[6]),
            .DI7(locmapin[7]),.DI8(locmapin[8]),.DI9(locmapin[9]),.DI10(locmapin[10]),.DI11(locmapin[11]),.DI12(locmapin[12]),.DI13(locmapin[13]),.DI14(locmapin[14]),.DI15(locmapin[15]),
            .DI16(locmapin[16]),.DI17(locmapin[17]),.DI18(locmapin[18]),.DI19(locmapin[19]),.DI20(locmapin[20]),.DI21(locmapin[21]),.DI22(locmapin[22]),.DI23(locmapin[23]),
            .DI24(locmapin[24]),.DI25(locmapin[25]),.DI26(locmapin[26]),.DI27(locmapin[27]),.DI28(locmapin[28]),.DI29(locmapin[29]),.DI30(locmapin[30]),.DI31(locmapin[31]),
            .DI32(locmapin[32]),.DI33(locmapin[33]),.DI34(locmapin[34]),.DI35(locmapin[35]),.DI36(locmapin[36]),.DI37(locmapin[37]),.DI38(locmapin[38]),.DI39(locmapin[39]),
            .DI40(locmapin[40]),.DI41(locmapin[41]),.DI42(locmapin[42]),.DI43(locmapin[43]),.DI44(locmapin[44]),.DI45(locmapin[45]),.DI46(locmapin[46]),.DI47(locmapin[47]),
            .DI48(locmapin[48]),.DI49(locmapin[49]),.DI50(locmapin[50]),.DI51(locmapin[51]),.DI52(locmapin[52]),.DI53(locmapin[53]),.DI54(locmapin[54]),.DI55(locmapin[55]),
            .DI56(locmapin[56]),.DI57(locmapin[57]),.DI58(locmapin[58]),.DI59(locmapin[59]),.DI60(locmapin[60]),.DI61(locmapin[61]),.DI62(locmapin[62]),.DI63(locmapin[63]),
            .DI64(locmapin[64]),.DI65(locmapin[65]),.DI66(locmapin[66]),.DI67(locmapin[67]),.DI68(locmapin[68]),.DI69(locmapin[69]),.DI70(locmapin[70]),.DI71(locmapin[71]),
            .DI72(locmapin[72]),.DI73(locmapin[73]),.DI74(locmapin[74]),.DI75(locmapin[75]),.DI76(locmapin[76]),.DI77(locmapin[77]),.DI78(locmapin[78]),.DI79(locmapin[79]),
            .DI80(locmapin[80]),.DI81(locmapin[81]),.DI82(locmapin[82]),.DI83(locmapin[83]),.DI84(locmapin[84]),.DI85(locmapin[85]),.DI86(locmapin[86]),.DI87(locmapin[87]),
            .DI88(locmapin[88]),.DI89(locmapin[89]),.DI90(locmapin[90]),.DI91(locmapin[91]),.DI92(locmapin[92]),.DI93(locmapin[93]),.DI94(locmapin[94]),.DI95(locmapin[95]),
            .DI96(locmapin[96]),.DI97(locmapin[97]),.DI98(locmapin[98]),.DI99(locmapin[99]),.DI100(locmapin[100]),.DI101(locmapin[101]),.DI102(locmapin[102]),.DI103(locmapin[103]),
            .DI104(locmapin[104]),.DI105(locmapin[105]),.DI106(locmapin[106]),.DI107(locmapin[107]),.DI108(locmapin[108]),.DI109(locmapin[109]),.DI110(locmapin[110]),
            .DI111(locmapin[111]),.DI112(locmapin[112]),.DI113(locmapin[113]),.DI114(locmapin[114]),.DI115(locmapin[115]),.DI116(locmapin[116]),.DI117(locmapin[117]),
            .DI118(locmapin[118]),.DI119(locmapin[119]),.DI120(locmapin[120]),.DI121(locmapin[121]),.DI122(locmapin[122]),.DI123(locmapin[123]),.DI124(locmapin[124]),.DI125(locmapin[125]),.DI126(locmapin[126]),.DI127(locmapin[127]),
            .CK(clk),.WEB(locmapweb),.OE(1'b1),.CS(1'b1));
MEM Weightmap(.A0(weimapaddr[0]),.A1(weimapaddr[1]),.A2(weimapaddr[2]),.A3(weimapaddr[3]),.A4(weimapaddr[4]),.A5(weimapaddr[5]),.A6(weimapaddr[6]),
			.DO0(weimapout[0]),.DO1(weimapout[1]),.DO2(weimapout[2]),.DO3(weimapout[3]),.DO4(weimapout[4]),.DO5(weimapout[5]),.DO6(weimapout[6]),
            .DO7(weimapout[7]),.DO8(weimapout[8]),.DO9(weimapout[9]),.DO10(weimapout[10]),.DO11(weimapout[11]),.DO12(weimapout[12]),.DO13(weimapout[13]),.DO14(weimapout[14]),.DO15(weimapout[15]),
            .DO16(weimapout[16]),.DO17(weimapout[17]),.DO18(weimapout[18]),.DO19(weimapout[19]),.DO20(weimapout[20]),.DO21(weimapout[21]),.DO22(weimapout[22]),.DO23(weimapout[23]),
            .DO24(weimapout[24]),.DO25(weimapout[25]),.DO26(weimapout[26]),.DO27(weimapout[27]),.DO28(weimapout[28]),.DO29(weimapout[29]),.DO30(weimapout[30]),.DO31(weimapout[31]),
            .DO32(weimapout[32]),.DO33(weimapout[33]),.DO34(weimapout[34]),.DO35(weimapout[35]),.DO36(weimapout[36]),.DO37(weimapout[37]),.DO38(weimapout[38]),.DO39(weimapout[39]),
            .DO40(weimapout[40]),.DO41(weimapout[41]),.DO42(weimapout[42]),.DO43(weimapout[43]),.DO44(weimapout[44]),.DO45(weimapout[45]),.DO46(weimapout[46]),.DO47(weimapout[47]),
            .DO48(weimapout[48]),.DO49(weimapout[49]),.DO50(weimapout[50]),.DO51(weimapout[51]),.DO52(weimapout[52]),.DO53(weimapout[53]),.DO54(weimapout[54]),.DO55(weimapout[55]),
            .DO56(weimapout[56]),.DO57(weimapout[57]),.DO58(weimapout[58]),.DO59(weimapout[59]),.DO60(weimapout[60]),.DO61(weimapout[61]),.DO62(weimapout[62]),.DO63(weimapout[63]),
            .DO64(weimapout[64]),.DO65(weimapout[65]),.DO66(weimapout[66]),.DO67(weimapout[67]),.DO68(weimapout[68]),.DO69(weimapout[69]),.DO70(weimapout[70]),.DO71(weimapout[71]),
            .DO72(weimapout[72]),.DO73(weimapout[73]),.DO74(weimapout[74]),.DO75(weimapout[75]),.DO76(weimapout[76]),.DO77(weimapout[77]),.DO78(weimapout[78]),.DO79(weimapout[79]),
            .DO80(weimapout[80]),.DO81(weimapout[81]),.DO82(weimapout[82]),.DO83(weimapout[83]),.DO84(weimapout[84]),.DO85(weimapout[85]),.DO86(weimapout[86]),.DO87(weimapout[87]),
            .DO88(weimapout[88]),.DO89(weimapout[89]),.DO90(weimapout[90]),.DO91(weimapout[91]),.DO92(weimapout[92]),.DO93(weimapout[93]),.DO94(weimapout[94]),.DO95(weimapout[95]),
            .DO96(weimapout[96]),.DO97(weimapout[97]),.DO98(weimapout[98]),.DO99(weimapout[99]),.DO100(weimapout[100]),.DO101(weimapout[101]),.DO102(weimapout[102]),.DO103(weimapout[103]),
            .DO104(weimapout[104]),.DO105(weimapout[105]),.DO106(weimapout[106]),.DO107(weimapout[107]),.DO108(weimapout[108]),.DO109(weimapout[109]),.DO110(weimapout[110]),
            .DO111(weimapout[111]),.DO112(weimapout[112]),.DO113(weimapout[113]),.DO114(weimapout[114]),.DO115(weimapout[115]),.DO116(weimapout[116]),.DO117(weimapout[117]),
            .DO118(weimapout[118]),.DO119(weimapout[119]),.DO120(weimapout[120]),.DO121(weimapout[121]),.DO122(weimapout[122]),.DO123(weimapout[123]),.DO124(weimapout[124]),.DO125(weimapout[125]),.DO126(weimapout[126]),.DO127(weimapout[127]),
			.DI0(weimapin[0]),.DI1(weimapin[1]),.DI2(weimapin[2]),.DI3(weimapin[3]),.DI4(weimapin[4]),.DI5(weimapin[5]),.DI6(weimapin[6]),
            .DI7(weimapin[7]),.DI8(weimapin[8]),.DI9(weimapin[9]),.DI10(weimapin[10]),.DI11(weimapin[11]),.DI12(weimapin[12]),.DI13(weimapin[13]),.DI14(weimapin[14]),.DI15(weimapin[15]),
            .DI16(weimapin[16]),.DI17(weimapin[17]),.DI18(weimapin[18]),.DI19(weimapin[19]),.DI20(weimapin[20]),.DI21(weimapin[21]),.DI22(weimapin[22]),.DI23(weimapin[23]),
            .DI24(weimapin[24]),.DI25(weimapin[25]),.DI26(weimapin[26]),.DI27(weimapin[27]),.DI28(weimapin[28]),.DI29(weimapin[29]),.DI30(weimapin[30]),.DI31(weimapin[31]),
            .DI32(weimapin[32]),.DI33(weimapin[33]),.DI34(weimapin[34]),.DI35(weimapin[35]),.DI36(weimapin[36]),.DI37(weimapin[37]),.DI38(weimapin[38]),.DI39(weimapin[39]),
            .DI40(weimapin[40]),.DI41(weimapin[41]),.DI42(weimapin[42]),.DI43(weimapin[43]),.DI44(weimapin[44]),.DI45(weimapin[45]),.DI46(weimapin[46]),.DI47(weimapin[47]),
            .DI48(weimapin[48]),.DI49(weimapin[49]),.DI50(weimapin[50]),.DI51(weimapin[51]),.DI52(weimapin[52]),.DI53(weimapin[53]),.DI54(weimapin[54]),.DI55(weimapin[55]),
            .DI56(weimapin[56]),.DI57(weimapin[57]),.DI58(weimapin[58]),.DI59(weimapin[59]),.DI60(weimapin[60]),.DI61(weimapin[61]),.DI62(weimapin[62]),.DI63(weimapin[63]),
            .DI64(weimapin[64]),.DI65(weimapin[65]),.DI66(weimapin[66]),.DI67(weimapin[67]),.DI68(weimapin[68]),.DI69(weimapin[69]),.DI70(weimapin[70]),.DI71(weimapin[71]),
            .DI72(weimapin[72]),.DI73(weimapin[73]),.DI74(weimapin[74]),.DI75(weimapin[75]),.DI76(weimapin[76]),.DI77(weimapin[77]),.DI78(weimapin[78]),.DI79(weimapin[79]),
            .DI80(weimapin[80]),.DI81(weimapin[81]),.DI82(weimapin[82]),.DI83(weimapin[83]),.DI84(weimapin[84]),.DI85(weimapin[85]),.DI86(weimapin[86]),.DI87(weimapin[87]),
            .DI88(weimapin[88]),.DI89(weimapin[89]),.DI90(weimapin[90]),.DI91(weimapin[91]),.DI92(weimapin[92]),.DI93(weimapin[93]),.DI94(weimapin[94]),.DI95(weimapin[95]),
            .DI96(weimapin[96]),.DI97(weimapin[97]),.DI98(weimapin[98]),.DI99(weimapin[99]),.DI100(weimapin[100]),.DI101(weimapin[101]),.DI102(weimapin[102]),.DI103(weimapin[103]),
            .DI104(weimapin[104]),.DI105(weimapin[105]),.DI106(weimapin[106]),.DI107(weimapin[107]),.DI108(weimapin[108]),.DI109(weimapin[109]),.DI110(weimapin[110]),
            .DI111(weimapin[111]),.DI112(weimapin[112]),.DI113(weimapin[113]),.DI114(weimapin[114]),.DI115(weimapin[115]),.DI116(weimapin[116]),.DI117(weimapin[117]),
            .DI118(weimapin[118]),.DI119(weimapin[119]),.DI120(weimapin[120]),.DI121(weimapin[121]),.DI122(weimapin[122]),.DI123(weimapin[123]),.DI124(weimapin[124]),.DI125(weimapin[125]),.DI126(weimapin[126]),.DI127(weimapin[127]),
            .CK(clk),.WEB(weimapweb),.OE(1'b1),.CS(1'b1));
endmodule

module DRAM_READ(clk,rst_n,readdramflag,frameid,weightreadflag, dram_read_out,weightsramdone,
				arid_m_inf,arburst_m_inf, arsize_m_inf, arlen_m_inf, 
				arvalid_m_inf, arready_m_inf, araddr_m_inf,rid_m_inf,
				rvalid_m_inf, rready_m_inf, rdata_m_inf,
				rlast_m_inf, rresp_m_inf);

parameter DATA_WIDTH =128;
parameter ADDR_WIDTH=32;
parameter ID_WIDTH=4;
input clk,rst_n,weightreadflag,weightsramdone,readdramflag;
input [4:0]frameid;
output reg [DATA_WIDTH-1:0] dram_read_out;

output wire [ID_WIDTH-1:0]      arid_m_inf;///y
output wire [1:0]            arburst_m_inf;///y
output wire [2:0]             arsize_m_inf;///y
output reg [7:0]               arlen_m_inf;///y
output reg                   arvalid_m_inf;///y
input  wire                  arready_m_inf;
output reg [ADDR_WIDTH-1:0]   araddr_m_inf;///y

input  wire [ID_WIDTH-1:0]       rid_m_inf;
input  wire                   rvalid_m_inf;
output reg                    rready_m_inf;///y
input  wire [DATA_WIDTH-1:0]   rdata_m_inf;
input  wire                    rlast_m_inf;
input  wire [1:0]              rresp_m_inf;

parameter addrvalid=0;
parameter readvalid=1;
reg state_r,nextstate_r;
assign arid_m_inf=4'd0;
assign arburst_m_inf=2'd1;
assign arsize_m_inf=3'b100;
assign arlen_m_inf=8'd127;

always @(posedge clk or negedge rst_n) begin
	if (!rst_n) state_r<=addrvalid;
	else state_r<=nextstate_r;
end

always @(*) begin
	nextstate_r=state_r;
	araddr_m_inf=0;
	arvalid_m_inf=0;
	rready_m_inf=0;
	dram_read_out=0;
	case (state_r)
		addrvalid:begin
			if (readdramflag) begin
				araddr_m_inf={16'd1,frameid,11'd0};
				arvalid_m_inf=1;
				if (arready_m_inf) nextstate_r=readvalid;
			end
			if (weightsramdone) begin
				nextstate_r=addrvalid;
			end
			else if(weightreadflag)begin
				araddr_m_inf={16'd2,frameid,11'd0};
				arvalid_m_inf=1;
				if (arready_m_inf) nextstate_r=readvalid;
			end
		end 
		readvalid:begin
			rready_m_inf=1;
			if (rvalid_m_inf) begin
				dram_read_out=rdata_m_inf;
			end
			if (rlast_m_inf) nextstate_r=addrvalid;
		end 
	endcase
end
endmodule

module DRAM_WRITE(clk,rst_n,writedramflag, frameid, dram_read_in,
				awid_m_inf,awburst_m_inf,awsize_m_inf,awlen_m_inf,
				awvalid_m_inf, awready_m_inf, awaddr_m_inf,
				wvalid_m_inf,wready_m_inf,wdata_m_inf, wlast_m_inf,
				bid_m_inf,bvalid_m_inf, bready_m_inf, bresp_m_inf);

parameter DATA_WIDTH =128;
parameter ADDR_WIDTH=32;
parameter ID_WIDTH=4;
input clk,rst_n,writedramflag;
input [4:0] frameid;
input [DATA_WIDTH-1:0] dram_read_in;
output wire [ID_WIDTH-1:0]      awid_m_inf;///y
output wire [1:0]            awburst_m_inf;///y
output wire [2:0]             awsize_m_inf;///y
output wire [7:0]              awlen_m_inf;///y
output reg                   awvalid_m_inf;///y
input  wire                  awready_m_inf;
output reg  [ADDR_WIDTH-1:0]  awaddr_m_inf;///y
output reg                    wvalid_m_inf;///y
input  wire                   wready_m_inf;
output wire [DATA_WIDTH-1:0]   wdata_m_inf;///y
output reg                     wlast_m_inf;///y

input  wire  [ID_WIDTH-1:0]      bid_m_inf;
input  wire                   bvalid_m_inf;
output reg                    bready_m_inf;///y
input  wire  [1:0]             bresp_m_inf;
parameter addrvalid=0;
parameter writevalid=1;
reg state_w,nextstste_w;
reg [6:0]cntforlength;
assign awid_m_inf=4'd0;
assign awburst_m_inf=2'd1;
assign awsize_m_inf=3'b100;
assign wdata_m_inf=dram_read_in;
assign awlen_m_inf=127;
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) cntforlength<=0;
	else begin
		if (wready_m_inf) begin
			if (cntforlength==127) begin
				cntforlength<=0;
			end
			else cntforlength<=cntforlength+1;
		end
		else cntforlength<=0;
	end
end

always @(posedge clk or negedge rst_n) begin
	if (!rst_n) state_w<=addrvalid;
	else state_w<=nextstste_w;
end

always @(*) begin
	nextstste_w=state_w;
	awaddr_m_inf = 0;
	awvalid_m_inf = 0;
	wvalid_m_inf = 0;
	bready_m_inf = 0;
	wlast_m_inf = 0;
	case (state_w)
		addrvalid:begin
			if (writedramflag) begin
				awaddr_m_inf={16'd1,frameid,11'd0};;
				awvalid_m_inf=1;
				if(awready_m_inf)nextstste_w=writevalid;
			end
		end 
		writevalid:begin
			wvalid_m_inf=1;
			bready_m_inf=1;
			if(cntforlength==awlen_m_inf) wlast_m_inf=1;
			if(bvalid_m_inf==1)nextstste_w=addrvalid;
		end 
	endcase
end
endmodule
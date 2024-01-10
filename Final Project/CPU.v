//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   (C) Copyright Laboratory System Integration and Silicon Implementation
//   All Right Reserved
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   ICLAB 2021 Final Project: Customized ISA Processor 
//   Author              : Hsi-Hao Huang
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   File Name   : CPU.v
//   Module Name : CPU.v
//   Release version : V1.0 (Release Date: 2021-May)
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################

module CPU(

				clk,
			  rst_n,
  
		   IO_stall,

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
       bready_m_inf,
                    
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
       rready_m_inf 

);
// Input port
input  wire clk, rst_n;
// Output port
output reg  IO_stall;

parameter ID_WIDTH = 4 , ADDR_WIDTH = 32, DATA_WIDTH = 16, DRAM_NUMBER=2, WRIT_NUMBER=1;

// AXI Interface wire connecttion for pseudo DRAM read/write
/* Hint:
  your AXI-4 interface could be designed as convertor in submodule(which used reg for output signal),
  therefore I declared output of AXI as wire in CPU
*/



// axi write address channel 
output  wire [WRIT_NUMBER * ID_WIDTH-1:0]        awid_m_inf;
output  wire [WRIT_NUMBER * ADDR_WIDTH-1:0]    awaddr_m_inf;
output  wire [WRIT_NUMBER * 3 -1:0]            awsize_m_inf;
output  wire [WRIT_NUMBER * 2 -1:0]           awburst_m_inf;
output  wire [WRIT_NUMBER * 7 -1:0]             awlen_m_inf;
output  wire [WRIT_NUMBER-1:0]                awvalid_m_inf;
input   wire [WRIT_NUMBER-1:0]                awready_m_inf;
// axi write data channel 
output  wire [WRIT_NUMBER * DATA_WIDTH-1:0]     wdata_m_inf;
output  wire [WRIT_NUMBER-1:0]                  wlast_m_inf;
output  wire [WRIT_NUMBER-1:0]                 wvalid_m_inf;
input   wire [WRIT_NUMBER-1:0]                 wready_m_inf;
// axi write response channel
input   wire [WRIT_NUMBER * ID_WIDTH-1:0]         bid_m_inf;
input   wire [WRIT_NUMBER * 2 -1:0]             bresp_m_inf;
input   wire [WRIT_NUMBER-1:0]             	   bvalid_m_inf;
output  wire [WRIT_NUMBER-1:0]                 bready_m_inf;
// -----------------------------
// axi read address channel 
output  wire [DRAM_NUMBER * ID_WIDTH-1:0]       arid_m_inf;
output  wire [DRAM_NUMBER * ADDR_WIDTH-1:0]   araddr_m_inf;
output  wire [DRAM_NUMBER * 7 -1:0]            arlen_m_inf;
output  wire [DRAM_NUMBER * 3 -1:0]           arsize_m_inf;
output  wire [DRAM_NUMBER * 2 -1:0]          arburst_m_inf;
output  wire [DRAM_NUMBER-1:0]               arvalid_m_inf;
input   wire [DRAM_NUMBER-1:0]               arready_m_inf;
// -----------------------------
// axi read data channel 
input   wire [DRAM_NUMBER * ID_WIDTH-1:0]         rid_m_inf;
input   wire [DRAM_NUMBER * DATA_WIDTH-1:0]     rdata_m_inf;
input   wire [DRAM_NUMBER * 2 -1:0]             rresp_m_inf;
input   wire [DRAM_NUMBER-1:0]                  rlast_m_inf;
input   wire [DRAM_NUMBER-1:0]                 rvalid_m_inf;
output  wire [DRAM_NUMBER-1:0]                 rready_m_inf;
// -----------------------------

//
//
// 
/* Register in each core:
  There are sixteen registers in your CPU. You should not change the name of those registers.
  TA will check the value in each register when your core is not busy.
  If you change the name of registers below, you must get the fail in this lab.
*/

reg signed [15:0] core_r0 , core_r1 , core_r2 , core_r3 ;
reg signed [15:0] core_r4 , core_r5 , core_r6 , core_r7 ;
reg signed [15:0] core_r8 , core_r9 , core_r10, core_r11;
reg signed [15:0] core_r12, core_r13, core_r14, core_r15;

//###########################################
//
// Wrtie down your design below
//
//###########################################

//####################################################
//                   FSM PARAMETER
//####################################################
parameter FETCH=0;
parameter WAIT=1;
parameter DECODE=2;
parameter CAL=3;
parameter LOAD=4;
parameter STORE=5;
parameter WRITEBACK=6;
//####################################################
//                    reg & wire
//####################################################
reg [2:0]state,nextstate;
reg signed [15:0]rs,rt,rd;
reg [11:0]PC;//point counter
reg signed [15:0]imm;
reg [2:0]opcode;
reg [15:0]instruction;
reg[15:0]data_out;
reg	data_web;
reg[6:0]data_addr;
reg[15:0]data_in;
reg[15:0]inst_out;
reg	inst_web;
reg[6:0]inst_addr;
reg[15:0]inst_in;
reg [3:0]writeback_reg;
reg[6:0]cntinstindex;
reg[6:0]cntdataindex;
reg signed[15:0]writeback_ans;
reg	instreadflag;
reg	datareadflag;
reg	[11:0]data_index;
reg	datawriteflag;
reg	canoutput;
reg first_inst;
reg first_data;
reg addflag;
reg loadorstoreflag;
reg beqflag;
reg [15:0]addnum1,addnum2;
reg signed [15:0]addans;
reg [15:0]inst_dram_out;
reg [15:0]data_dram_out;
reg data_valid;
reg inst_valid;
reg data_ready;
reg inst_ready;
reg[11:0] data_idx_cur;
reg[11:0] inst_idx_cur;
reg waittrueinst;
reg waittruedata;
//####################################################
//                       FSM
//####################################################
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		state<=FETCH;
	end
	else state<=nextstate;
end

always @(*) begin
	case (state)
		FETCH:begin
			if (rvalid_m_inf[1]&&first_inst) nextstate=DECODE;
			else if(waittrueinst)nextstate=WAIT;
			else nextstate=FETCH;
		end 
		WAIT:nextstate=DECODE;
		DECODE:begin
			nextstate=CAL;
		end
		CAL:begin
			if (opcode[1]) begin
				if (data_ready)begin
					if(opcode[0])nextstate=STORE;
					else nextstate=LOAD;
				end
				else nextstate=CAL;
			end
			else nextstate=WRITEBACK;
		end
		LOAD:begin
			if (waittruedata||(rvalid_m_inf[0]&&first_data)) begin
				nextstate=WRITEBACK;
			end
			else nextstate=LOAD;
		end
		STORE:begin
			if (bvalid_m_inf) begin
				nextstate=FETCH;
			end
			else nextstate=STORE;
		end
		WRITEBACK:begin
			nextstate=FETCH;
		end
		default:nextstate=FETCH; 
	endcase
end
//####################################################
//                 core register
//####################################################
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		core_r0<=0;
		core_r1<=0;
		core_r2<=0;
		core_r3<=0;
		core_r4<=0;
		core_r5<=0;
		core_r6<=0;
		core_r7<=0;
		core_r8<=0;
		core_r9<=0;
		core_r10<=0;
		core_r11<=0;
		core_r12<=0;
		core_r13<=0;
		core_r14<=0;
		core_r15<=0;
	end
	else begin
		if (state==WRITEBACK&&!opcode[2]) begin
			case (writeback_reg)
				4'd0:core_r0<=writeback_ans; 
				4'd1:core_r1<=writeback_ans;
				4'd2:core_r2<=writeback_ans;
				4'd3:core_r3<=writeback_ans;
				4'd4:core_r4<=writeback_ans;
				4'd5:core_r5<=writeback_ans;
				4'd6:core_r6<=writeback_ans;
				4'd7:core_r7<=writeback_ans;
				4'd8:core_r8<=writeback_ans;
				4'd9:core_r9<=writeback_ans;
				4'd10:core_r10<=writeback_ans;
				4'd11:core_r11<=writeback_ans;
				4'd12:core_r12<=writeback_ans;
				4'd13:core_r13<=writeback_ans;
				4'd14:core_r14<=writeback_ans;
				4'd15:core_r15<=writeback_ans;
			endcase
		end
	end
end
//####################################################
//                 rs & rt & rd & PC
//####################################################
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		instruction<=0;
	end
	else begin
		if ((state==FETCH&&rvalid_m_inf[1]&&first_inst)||state==WAIT) begin
			instruction<=inst_dram_out;
		end
	end
end
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		rs<=0;
	end
	else begin
		case (instruction[12:9])
			4'd0:rs<=core_r0;
			4'd1:rs<=core_r1;
			4'd2:rs<=core_r2;
			4'd3:rs<=core_r3;
			4'd4:rs<=core_r4;
			4'd5:rs<=core_r5;
			4'd6:rs<=core_r6;
			4'd7:rs<=core_r7;
			4'd8:rs<=core_r8;
			4'd9:rs<=core_r9;
			4'd10:rs<=core_r10;
			4'd11:rs<=core_r11;
			4'd12:rs<=core_r12;
			4'd13:rs<=core_r13;
			4'd14:rs<=core_r14;
			4'd15:rs<=core_r15;
		endcase
	end
end
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		rt<=0;
	end
	else begin
		if (state==DECODE) begin
			case (instruction[8:5])
				4'd0:rt<=core_r0;
				4'd1:rt<=core_r1;
				4'd2:rt<=core_r2;
				4'd3:rt<=core_r3;
				4'd4:rt<=core_r4;
				4'd5:rt<=core_r5;
				4'd6:rt<=core_r6;
				4'd7:rt<=core_r7;
				4'd8:rt<=core_r8;
				4'd9:rt<=core_r9;
				4'd10:rt<=core_r10;
				4'd11:rt<=core_r11;
				4'd12:rt<=core_r12;
				4'd13:rt<=core_r13;
				4'd14:rt<=core_r14;
				4'd15:rt<=core_r15;
			endcase
		end
		else if(state==LOAD)begin
			rt<=data_dram_out;
		end
	end
end
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		rd<=0;
	end
	else begin
		if (state==CAL) begin
			case ({opcode,instruction[0]})
				4'b0001:rd<=rs-rt;
				4'b0010:rd<=(rs<rt)?1:0;
				4'b0011:rd<=rs*rt;
				default:rd<=addans;
			endcase
		end
	end
end
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		PC<=0;
	end
	else begin
		if ((state==FETCH&&rvalid_m_inf[1]&&first_inst)||state==WAIT) begin
			PC<=PC+2;
		end
		else if (state==WRITEBACK) begin
			if (opcode[2]) begin
				if (opcode[0]) PC<=instruction[12:0];
				else if (rs==rt) PC<=rd;
			end
		end
	end
end
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		opcode<=0;
	end
	else opcode<=instruction[15:13];
end
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		imm<=0;
	end
	else imm<=$signed(instruction[4:0]);
end
//####################################################
//              OTHER CONTROL SIGNAL
//####################################################
always @(*) begin
	if (rvalid_m_inf[0]&&first_data) begin
		data_dram_out=rdata_m_inf[15:0];
	end
	else data_dram_out=data_out;
end
always @(*) begin
	if (rvalid_m_inf[1]&&first_inst) begin
		inst_dram_out=rdata_m_inf[31:16];
	end
	else inst_dram_out=inst_out;
end
always @(*) begin
	data_index=rd<<1;
end
always @(*) begin
	if (state==FETCH) instreadflag=1;
	else instreadflag=0;
end
always @(*) begin
	if (!opcode) addflag=1;
	else addflag=0;
end
always @(*) begin
	if (opcode[1])loadorstoreflag=1;
	else loadorstoreflag=0;
end
always @(*) begin
	if (opcode[2])beqflag=1;
	else beqflag=0;
end
always @(*) begin
	if (state==STORE) begin
		datawriteflag=1;
	end
	else datawriteflag=0;
end
always @(*) begin
	if (state==LOAD) begin
		datareadflag=1;
	end
	else datareadflag=0;
end
//####################################################
//                    CAL 
//####################################################
always @(*) begin
	if (addflag) begin
		addnum1=rs;
		addnum2=rt;
	end
	else if(loadorstoreflag)begin
		addnum1=rs;
		addnum2=imm;
	end
	else if(beqflag)begin
		addnum1=PC;
		addnum2=imm*2;
	end
	else begin
		addnum1=0;
		addnum2=0;
	end
end
always @(*) begin
	addans=addnum1+addnum2;
end
always @(*) begin
	if (instruction[14]) writeback_reg=instruction[8:5];
	else writeback_reg=instruction[4:1];
end
always @(*) begin
	if (instruction[14])writeback_ans=rt;
	else writeback_ans=rd;
end
//####################################################
//               DATA SRAM CONTROL
//####################################################
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		data_web<=1;
	end
	else begin
		if (state==STORE) begin
			if ((data_idx_cur+254>=data_index)&&(data_idx_cur<=data_index))begin
				data_web<=0;
			end
			else data_web<=1;
		end
		else begin
			if (rvalid_m_inf[0]) begin
				data_web<=0;
			end
			else data_web<=1;
		end
	end
end
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		data_addr<=0;
	end
	else begin
		if (rvalid_m_inf[0])data_addr<=cntdataindex;
		else if (state==STORE||state==LOAD) begin
			data_addr<=(data_index-data_idx_cur)/2;			
		end
		else data_addr<=0;
	end
end
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		data_in<=0;
	end
	else begin
		if (rvalid_m_inf[0])data_in<=rdata_m_inf[15:0];
		else if (state==STORE) data_in<=rt;
		else data_in<=0;
	end
end
//####################################################
//                   OUTPUT
//####################################################
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		canoutput<=0;
	end
	else begin
		if (state==FETCH&&canoutput) begin
			canoutput<=0;
		end
		else if(state==DECODE)canoutput<=1;
	end
end
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		IO_stall<=1;
	end
	else if(state==FETCH&&canoutput)IO_stall<=0;
	else IO_stall<=1;
end
//####################################################
//              DRAM AXI and SRAM module
//####################################################
AXI4_READ READ_DRAM(
	.arid_m_inf(arid_m_inf),.arburst_m_inf(arburst_m_inf), .arsize_m_inf(arsize_m_inf), .arlen_m_inf(arlen_m_inf), .arvalid_m_inf(arvalid_m_inf), .arready_m_inf(arready_m_inf), .araddr_m_inf(araddr_m_inf),
	.rid_m_inf(rid_m_inf),.rvalid_m_inf(rvalid_m_inf), .rready_m_inf(rready_m_inf), .rdata_m_inf(rdata_m_inf),.rlast_m_inf(rlast_m_inf),.rresp_m_inf(rresp_m_inf),
	.clk(clk),.rst_n(rst_n),.PC(PC),.data_index(data_index),.data_valid(data_valid),.inst_valid(inst_valid),.first_data(first_data),.first_inst(first_inst),.data_ready(data_ready),.inst_ready(inst_ready),.data_idx_cur(data_idx_cur),
	.cntdataindex(cntdataindex),.data_out(data_out),.inst_web(inst_web),.inst_addr(inst_addr),.inst_in(inst_in), .inst_out(inst_out),.instreadflag(instreadflag),.datareadflag(datareadflag),.waittrueinst(waittrueinst),.waittruedata(waittruedata)
);
AXI_DATA_WRITE WRITE_DRAM( 
	.awid_m_inf(awid_m_inf),.awburst_m_inf(awburst_m_inf), .awsize_m_inf(awsize_m_inf), .awlen_m_inf(awlen_m_inf),.awvalid_m_inf(awvalid_m_inf), .awready_m_inf(awready_m_inf), .awaddr_m_inf(awaddr_m_inf),
   	.wvalid_m_inf(wvalid_m_inf), .wready_m_inf(wready_m_inf),.wdata_m_inf(wdata_m_inf), .wlast_m_inf(wlast_m_inf),
    .bid_m_inf(bid_m_inf),.bvalid_m_inf(bvalid_m_inf), .bready_m_inf(bready_m_inf), .bresp_m_inf(bresp_m_inf),
	.clk(clk),.rst_n(rst_n),.datawriteflag(datawriteflag),.data_index(data_index), .writedata(rt)
);
cashe data (.A0(data_addr[0]),.A1(data_addr[1]),.A2(data_addr[2]),.A3(data_addr[3]),.A4(data_addr[4]),.A5(data_addr[5]),.A6(data_addr[6]),
            .DO0(data_out[0]),.DO1(data_out[1]),.DO2(data_out[2]),.DO3(data_out[3]),.DO4(data_out[4]),.DO5(data_out[5]),.DO6(data_out[6]),
            .DO7(data_out[7]),.DO8(data_out[8]),.DO9(data_out[9]),.DO10(data_out[10]),.DO11(data_out[11]),.DO12(data_out[12]),.DO13(data_out[13]),.DO14(data_out[14]),.DO15(data_out[15]),
            .DI0(data_in[0]),.DI1(data_in[1]),.DI2(data_in[2]),.DI3(data_in[3]),.DI4(data_in[4]),.DI5(data_in[5]),.DI6(data_in[6]),
            .DI7(data_in[7]),.DI8(data_in[8]),.DI9(data_in[9]),.DI10(data_in[10]),.DI11(data_in[11]),.DI12(data_in[12]),.DI13(data_in[13]),.DI14(data_in[14]),.DI15(data_in[15]),
            .CK(clk),.WEB(data_web),.OE(1'b1),.CS(1'b1)
);
cashe inst (.A0(inst_addr[0]),.A1(inst_addr[1]),.A2(inst_addr[2]),.A3(inst_addr[3]),.A4(inst_addr[4]),.A5(inst_addr[5]),.A6(inst_addr[6]),
            .DO0(inst_out[0]),.DO1(inst_out[1]),.DO2(inst_out[2]),.DO3(inst_out[3]),.DO4(inst_out[4]),.DO5(inst_out[5]),.DO6(inst_out[6]),
            .DO7(inst_out[7]),.DO8(inst_out[8]),.DO9(inst_out[9]),.DO10(inst_out[10]),.DO11(inst_out[11]),.DO12(inst_out[12]),.DO13(inst_out[13]),.DO14(inst_out[14]),.DO15(inst_out[15]),
            .DI0(inst_in[0]),.DI1(inst_in[1]),.DI2(inst_in[2]),.DI3(inst_in[3]),.DI4(inst_in[4]),.DI5(inst_in[5]),.DI6(inst_in[6]),
            .DI7(inst_in[7]),.DI8(inst_in[8]),.DI9(inst_in[9]),.DI10(inst_in[10]),.DI11(inst_in[11]),.DI12(inst_in[12]),.DI13(inst_in[13]),.DI14(inst_in[14]),.DI15(inst_in[15]),
            .CK(clk),.WEB(inst_web),.OE(1'b1),.CS(1'b1)
);

endmodule

module AXI4_READ(
	clk,
	rst_n,
	arid_m_inf,
	arburst_m_inf,
	arsize_m_inf,
	arlen_m_inf, 
	arvalid_m_inf,
	arready_m_inf,
	araddr_m_inf,
	rid_m_inf,
	rvalid_m_inf,
	rready_m_inf,
	rdata_m_inf,
	rlast_m_inf,
	rresp_m_inf,
	instreadflag,
	datareadflag,
	PC,
	data_index, 
	data_valid,
	inst_valid,
	data_ready,
	inst_ready,
	data_idx_cur,
	cntdataindex,
	data_out,
	first_inst,
	first_data,
	inst_web,
	inst_addr,
	inst_in,
	inst_out,
	waittrueinst,
	waittruedata
);
parameter ID_WIDTH = 4 , ADDR_WIDTH = 32, DATA_WIDTH = 16, DRAM_NUMBER=2, WRIT_NUMBER=1;


input clk,rst_n;
input instreadflag;
input datareadflag;
input [11:0] data_index;
input [11:0] PC;
input [15:0] inst_out;
input [15:0] data_out;
output reg data_valid;
output reg inst_valid;
output reg data_ready;
output reg inst_ready;
output reg inst_web;
output reg [6:0] inst_addr;
output reg [15:0] inst_in;
output reg first_inst;
output reg first_data;
output reg[11:0]data_idx_cur;
output reg[6:0]cntdataindex;
output reg waittrueinst;
output reg waittruedata;
// (1)	axi read address channel 
output  reg [DRAM_NUMBER * ID_WIDTH-1:0]       arid_m_inf;
output  reg [DRAM_NUMBER * ADDR_WIDTH-1:0]   araddr_m_inf;
output  reg [DRAM_NUMBER * 7 -1:0]            arlen_m_inf;
output  reg [DRAM_NUMBER * 3 -1:0]           arsize_m_inf;
output  reg [DRAM_NUMBER * 2 -1:0]          arburst_m_inf;
output  reg	 [DRAM_NUMBER-1:0]               arvalid_m_inf;
input   wire [DRAM_NUMBER-1:0]               arready_m_inf;
// (2)	axi read data channel 
input   wire [DRAM_NUMBER * ID_WIDTH-1:0]         rid_m_inf;
input   wire [DRAM_NUMBER * DATA_WIDTH-1:0]     rdata_m_inf;
input   wire [DRAM_NUMBER * 2 -1:0]             rresp_m_inf;
input   wire [DRAM_NUMBER-1:0]                  rlast_m_inf;
input   wire [DRAM_NUMBER-1:0]                 rvalid_m_inf;
output  reg  [DRAM_NUMBER-1:0]                 rready_m_inf;

parameter ADDR_VALID=2'd0;
parameter READ_VALID=2'd1;
parameter NOT_FIRST_OUT=2'd3;

reg	[1:0]state_i;
reg	[1:0]nextstate_i;
reg [31:0]inst_dram_addr;
reg [31:0]data_dram_addr;
reg	[1:0]state_d;
reg	[1:0]nextstate_d;
reg	[11:0]inst_idx_cur;
reg	[6:0]cntinstindex;
reg	firstread;
reg	firstread_d;
reg canreaddata;
reg canreadinst;

always @(*) begin
	arid_m_inf=8'd0; 			
	arburst_m_inf=4'b0101;		
	arsize_m_inf={3'b001,3'b001};
	arlen_m_inf={7'd127,7'd127};
	araddr_m_inf={inst_dram_addr,data_dram_addr};
end



//####################################################
//            INSTRUCTION READ FSM
//####################################################
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		state_i<=ADDR_VALID;
	end
	else state_i<=nextstate_i;
end
always @ (*) begin
	case (state_i)
		ADDR_VALID:begin
			if (instreadflag)begin
				if (canreadinst)begin
					if (arready_m_inf[1])begin
						nextstate_i = READ_VALID;
					end
					else nextstate_i=ADDR_VALID;
				end
				else nextstate_i = NOT_FIRST_OUT;
			end
			else nextstate_i=ADDR_VALID;
		end
		READ_VALID:begin
			if (rlast_m_inf[1]) nextstate_i = ADDR_VALID;
			else nextstate_i=READ_VALID;
		end
		NOT_FIRST_OUT:begin
			nextstate_i = ADDR_VALID;
		end
		default:nextstate_i=ADDR_VALID;
	endcase
end
//####################################################
//            INSTRUCTION READ CONTROL
//####################################################
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		waittrueinst<=0;
	end
	else if (nextstate_i==NOT_FIRST_OUT) waittrueinst<=1;
	else waittrueinst<=0;
end
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		firstread<=0;
	end
	else if (arready_m_inf[1]) firstread<=1; 
end
always @(*) begin
	if (((inst_idx_cur>PC)||(inst_idx_cur+254<PC)||!firstread)) begin
		canreadinst=1;
	end
	else canreadinst=0;
end
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		inst_idx_cur<=0;
	end
	else begin
		if (arready_m_inf[1]) begin
			inst_idx_cur<=inst_dram_addr[11:0];
		end
	end
end
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		arvalid_m_inf[1]<=0;
	end
	else if (inst_dram_addr!=0&&!arready_m_inf[1]&&canreadinst&&instreadflag&&state_i==ADDR_VALID) arvalid_m_inf[1]<=1;
	else arvalid_m_inf[1]<=0;
end
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		inst_dram_addr<=0;
	end
	else begin
		if (PC<=125) inst_dram_addr<={16'd0,16'h1000};
		else if (PC>=3967) inst_dram_addr<={16'd0,16'h1F00};
		else inst_dram_addr<=3970+PC;
	end
end
always@(posedge clk or negedge rst_n) begin
	if(!rst_n) rready_m_inf[1]<=0;
	else if(state_i==ADDR_VALID&&arready_m_inf[1]) rready_m_inf[1]<=1;
	else if(state_i==READ_VALID&&rlast_m_inf[1]) rready_m_inf[1]<=0;
end
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		cntinstindex<=0;
	end
	else if (rvalid_m_inf[1]) cntinstindex<=cntinstindex+1;
	else cntinstindex<=0;
end
always @(*) begin
	if (state_i==ADDR_VALID) begin
		inst_ready=1;
	end
	else inst_ready=0;
end
always @(*) begin
	if (cntinstindex==(PC-inst_idx_cur)>>1) begin
		first_inst=1;
	end
	else first_inst=0;
end
always @(*) begin
	if ((state_i==READ_VALID&&rvalid_m_inf[1]&&first_inst)||nextstate_i==NOT_FIRST_OUT) begin
		inst_valid=1;
	end
	else inst_valid=0;
end
//####################################################
//            INSTRUCTION SRAM SIGNAL
//####################################################
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		inst_web<=1;
	end
	else begin
		if (state_i==READ_VALID&&rvalid_m_inf[1]) inst_web<=0;
		else inst_web<=1;
	end
end
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		inst_addr<=0;
	end
	else begin
		if (rvalid_m_inf[1])inst_addr<=cntinstindex;
		else inst_addr<=(PC-inst_idx_cur)/2;
	end
end
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		inst_in<=0;
	end
	else inst_in<=rdata_m_inf[31:16];
end
//####################################################
//                  DATA READ FSM
//####################################################
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		state_d<=ADDR_VALID;
	end
	else state_d<=nextstate_d;
end
always @(*) begin
	case (state_d)
		ADDR_VALID:begin
			if (datareadflag)begin
				if (canreaddata)begin
					if (arready_m_inf[0])nextstate_d=READ_VALID;
					else nextstate_d=ADDR_VALID;
				end
				else nextstate_d=NOT_FIRST_OUT;
			end
			else nextstate_d=ADDR_VALID;
		end
		READ_VALID:begin
			if (rlast_m_inf[0]) nextstate_d = ADDR_VALID;
			else nextstate_d=READ_VALID;
		end
		NOT_FIRST_OUT:begin
			nextstate_d = ADDR_VALID;
		end
		default:nextstate_d=ADDR_VALID;
	endcase
end
//####################################################
//                DATA READ CONTROL
//####################################################
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		waittruedata<=0;
	end
	else if (state_d==NOT_FIRST_OUT) begin
		waittruedata<=1;
	end
	else waittruedata<=0;
end
always @(*) begin
	if ((data_idx_cur>data_index)||(data_idx_cur + 254<data_index)||!firstread_d)canreaddata=1;
	else canreaddata=0;
end
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		firstread_d<=0;
	end
	else if (arready_m_inf[0]) firstread_d<=1; 
end
always@(posedge clk or negedge rst_n) begin
	if(!rst_n) rready_m_inf[0]<=0;
	else if(state_d==ADDR_VALID&&arready_m_inf[0]) rready_m_inf[0]<=1;
	else if(state_d==READ_VALID&&rlast_m_inf[0]) rready_m_inf[0]<=0;
end
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		data_idx_cur<=0;
	end
	else begin
		if (rvalid_m_inf[0]) begin
			data_idx_cur<=data_dram_addr[11:0];
		end
	end
end
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		cntdataindex<=0;
	end
	else begin
		if (rvalid_m_inf[0]) cntdataindex<=cntdataindex+1;
		else cntdataindex<=0;
	end
end
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		data_dram_addr<=0;
	end
	else begin
		if (datareadflag&&canreaddata)begin
			if (data_index<=125)data_dram_addr<={16'd0,16'h1000};
			else if (data_index>=3967)data_dram_addr<={16'd0,16'h1F00};
			else data_dram_addr<=3970+data_index;
		end
	end
end
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		arvalid_m_inf[0]<=0;
	end
	else begin
		if (datareadflag&&state_d==ADDR_VALID&&data_dram_addr!=0&&!arready_m_inf&&canreaddata) begin
			arvalid_m_inf[0]<=1;
		end
		else arvalid_m_inf[0]<=0;
	end
end
always @(*) begin
	if (cntdataindex==(data_index-data_idx_cur)>>1)first_data=1;
	else first_data=0;
end
always @(*) begin
	if (state_d==ADDR_VALID) begin
		data_ready=1;
	end
	else data_ready=0;
end
always @(*) begin
	if ((state_d==READ_VALID&&rvalid_m_inf[0]&&first_data)||state_d==NOT_FIRST_OUT) begin
		data_valid=1;
	end
	else data_valid=0;
end
endmodule

module AXI_DATA_WRITE(
	clk,
	rst_n,
	awid_m_inf,
	awburst_m_inf,
	awsize_m_inf,
	awlen_m_inf,
	awvalid_m_inf,
	awready_m_inf,
	awaddr_m_inf,
   	wvalid_m_inf,
	wready_m_inf,
	wdata_m_inf,
	wlast_m_inf,
    bid_m_inf,
	bvalid_m_inf,
	bready_m_inf,
	bresp_m_inf,
	datawriteflag,
	data_index,
	writedata
);
parameter ID_WIDTH = 4 , ADDR_WIDTH = 32, DATA_WIDTH = 16, DRAM_NUMBER=2, WRIT_NUMBER=1;

input clk,rst_n;
input datawriteflag;
input [11:0] data_index;
input [DATA_WIDTH-1:0] writedata;
// (1) 	axi write address channel 
output  reg [WRIT_NUMBER * ID_WIDTH-1:0]        awid_m_inf;
output  reg  [WRIT_NUMBER * ADDR_WIDTH-1:0]    awaddr_m_inf;
output  reg [WRIT_NUMBER * 3 -1:0]            awsize_m_inf;
output  reg [WRIT_NUMBER * 2 -1:0]           awburst_m_inf;
output  reg [WRIT_NUMBER * 7 -1:0]             awlen_m_inf;
output  reg  [WRIT_NUMBER-1:0]                awvalid_m_inf;
input   wire [WRIT_NUMBER-1:0]                awready_m_inf;
// (2)	axi write data channel 
output  reg [WRIT_NUMBER * DATA_WIDTH-1:0]     wdata_m_inf;
output  reg  [WRIT_NUMBER-1:0]                  wlast_m_inf;
output  reg  [WRIT_NUMBER-1:0]                 wvalid_m_inf;
input   wire [WRIT_NUMBER-1:0]                 wready_m_inf;
// (3)	axi write response channel 
input   wire [WRIT_NUMBER * ID_WIDTH-1:0]         bid_m_inf;
input   wire [WRIT_NUMBER * 2 -1:0]             bresp_m_inf;
input   wire [WRIT_NUMBER-1:0]             	   bvalid_m_inf;
output  reg  [WRIT_NUMBER-1:0]                 bready_m_inf;

reg canreadaddr;

always @(*) begin
	awid_m_inf=4'd0;
	awburst_m_inf=2'd1;
	awsize_m_inf=3'b001;
	wdata_m_inf=writedata;
	wlast_m_inf=wvalid_m_inf;
	awlen_m_inf=0;
end

//####################################################
//            DATA WRITE CONTROL
//####################################################
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		canreadaddr<=0;
	end
	else if (awready_m_inf) canreadaddr<=1;
	else if (bvalid_m_inf) canreadaddr<=0;
end
always @(posedge clk or negedge rst_n) begin
	if (!rst_n)bready_m_inf<=0;
	else if (awready_m_inf) bready_m_inf<=1;
	else if (bvalid_m_inf)bready_m_inf<=0;
end
always @(posedge clk or negedge rst_n) begin
	if (!rst_n)
		wvalid_m_inf<=0;
	else if (awready_m_inf)
		wvalid_m_inf<=1;
	else if (wready_m_inf)
		wvalid_m_inf<=0;
end
always @ (posedge clk or negedge rst_n)begin
	if (!rst_n) begin
		awaddr_m_inf<=0;
	end
	else awaddr_m_inf<=32'h00001000+data_index;
end
always @(posedge clk or negedge rst_n) begin
	if (!rst_n)begin
		awvalid_m_inf<=0;
	end
	else if (!canreadaddr&&datawriteflag&&!awready_m_inf) awvalid_m_inf<=1;
	else awvalid_m_inf<=0;
end

endmodule
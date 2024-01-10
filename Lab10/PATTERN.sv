/*
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
NYCU Institute of Electronic
2023 Autumn IC Design Laboratory 
Lab09: SystemVerilog Design and Verification 
File Name   : PATTERN.sv
Module Name : PATTERN
Release version : v1.0 (Release Date: Nov-2023)
Author : Jui-Huang Tsai (erictsai.10@nycu.edu.tw)
//   (C) Copyright Laboratory System Integration and Silicon Implementation
//   All Right Reserved
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
*/

`include "Usertype_BEV.sv"

program automatic PATTERN(input clk, INF.PATTERN inf);
import usertype::*;

parameter patnum=3600;
parameter seed=573666;



//================================================================
// parameters & integer
//================================================================
parameter DRAM_p_r = "../00_TESTBED/DRAM/dram.dat";
integer gap;
integer latency;
integer tot_lat;
integer patcnt;
integer makecnt;



//================================================================
// wire & registers 
//================================================================
logic [7:0] golden_DRAM [((65536+8*256)-1):(65536+0)];  // 256 box
logic golden_complete;
Error_Msg golden_err_msg;
logic [1:0]action;
logic [2:0] TYPE;
logic[1:0] SIZE;
logic [3:0]todaymonth;
logic [4:0]todaydate;
logic [7:0]Boxnumber;
Bev_Bal tea;
logic [9:0]b_tea_min,milk_min,g_tea_min,ppj_min;
logic [11:0]supplying1,supplying2,supplying3,supplying4;
logic [12:0]bt_total,gt_total,m_total,pj_total;
logic [1:0]cnt4;
logic complete;

//================================================================
// class random
//================================================================
class randomaction;
    randc logic[1:0] action;
    function new(int seed);
        this.srandom(seed);
    endfunction
    constraint range{action inside{
                     Make_drink,
                     Supply,
					 Check_Valid_Date
                     };
    }
endclass
class randomtype;
    randc logic[2:0] TYPE;
    function new(int seed);
        this.srandom(seed);
    endfunction
    constraint range{TYPE inside{
                     Black_Tea,
					 Milk_Tea,
					 Extra_Milk_Tea,
					 Green_Tea,
                     Green_Milk_Tea,
                     Pineapple_Juice,
                     Super_Pineapple_Tea,
                     Super_Pineapple_Milk_Tea
                    };
    }           
endclass
class randomsize;
    randc logic[1:0] SIZE;
    function new(int seed);
        this.srandom(seed);
    endfunction
    constraint range{SIZE inside{
                     L,
					 M,
					 S
                    };
    }
endclass
class randomdate;
    randc logic[3:0]todaymonth;
    randc logic[4:0]todaydate;
    function new(int seed);
        this.srandom(seed);
    endfunction
    constraint range{
        todaymonth inside{[1:12]};
        (todaymonth==1)->todaydate  inside{[1:31]}; 
        (todaymonth==2)->todaydate  inside{[1:28]}; 
        (todaymonth==3)->todaydate  inside{[1:31]};
        (todaymonth==4)->todaydate  inside{[1:30]}; 
        (todaymonth==5)->todaydate  inside{[1:31]}; 
        (todaymonth==6)->todaydate  inside{[1:30]};  
        (todaymonth==7)->todaydate  inside{[1:31]}; 
        (todaymonth==8)->todaydate  inside{[1:31]}; 
        (todaymonth==9)->todaydate  inside{[1:30]}; 
        (todaymonth==10)->todaydate inside{[1:31]}; 
        (todaymonth==11)->todaydate inside{[1:30]}; 
        (todaymonth==12)->todaydate inside{[1:31]}; 
    }
endclass 
class randomboxnum;
    randc logic[7:0]Boxnumber;
    function new(int seed); 
		this.srandom(seed); 
	endfunction
    constraint range{
        Boxnumber inside{[0:255]};
    }
endclass
class randomsup_ing;
    randc logic [11:0]supplying1;
    randc logic [11:0]supplying2;
    randc logic [11:0]supplying3;
    randc logic [11:0]supplying4;
    function new(int seed);
        this.srandom(seed);
    endfunction
    constraint range{
        supplying1 inside{[0:4095]};
        supplying2 inside{[0:4095]};
        supplying3 inside{[0:4095]};
        supplying4 inside{[0:4095]};
    }
endclass

randomaction random_action =new(seed);
randomtype random_type=new(seed);
randomsize random_size=new(seed);
randomdate random_month_date=new(seed);
randomboxnum random_boxnum=new(seed);
randomsup_ing random_sup_ing=new(seed);
//================================================================
// initial
//================================================================
initial $readmemh(DRAM_p_r,golden_DRAM);
initial exetask;


task exetask;begin
    resettask;
    for (integer i=0 ;i<patnum ;i++ ) begin
        dramtask;
        actiontask;
        wait_out_valid_task;
        checkoutputtask;
        if (action!=2)storetask;
        tot_lat=tot_lat+latency; 
        patcnt++;
        $display("\033[0;34mPass Pattern No.%4d \033[m \033[0;32mLatency : %3d\033[m",i,latency); 
    end
    youpasstask;
end
endtask


task resettask;begin
    inf.rst_n            = 1;
    inf.sel_action_valid = 0;
    inf.type_valid       = 0;
    inf.size_valid       = 0;
    inf.date_valid       = 0;
    inf.box_no_valid     = 0;
    inf.box_sup_valid    = 0;
    inf.D                = 'dx;
    tot_lat              = 0;
    patcnt               =0;
    makecnt              =0;
    #(10) inf.rst_n = 0;
    #(10) inf.rst_n = 1;
end
endtask

task dramtask;begin
    random_boxnum.randomize();
    Boxnumber=random_boxnum.Boxnumber;
    tea.black_tea = {golden_DRAM[(65536 + Boxnumber*8 + 7)], golden_DRAM[(65536 + Boxnumber*8 + 6)][7:4]};
    tea.green_tea = {golden_DRAM[(65536 + Boxnumber*8 + 6)][3:0], golden_DRAM[(65536 + Boxnumber*8 + 5)]};
    tea.M = golden_DRAM[(65536 + Boxnumber*8 + 4)][3:0];
    tea.milk = {golden_DRAM[(65536 + Boxnumber*8 + 3)], golden_DRAM[(65536 + Boxnumber*8 + 2)][7:4]};
    tea.pineapple_juice = {golden_DRAM[(65536 + Boxnumber*8 + 2)][3:0], golden_DRAM[(65536 + Boxnumber*8 + 1)]};
    tea.D = golden_DRAM[(65536 + Boxnumber*8 + 0)][4:0];
end
endtask

task actiontask; begin
    if (patcnt<1800)begin
        if (patcnt%9==0||patcnt%9==1||patcnt%9==6) action=Make_drink;
        else if(patcnt%9==2||patcnt%9==3||patcnt%9==8) action=Supply;
        else if(patcnt%9==4||patcnt%9==5||patcnt%9==7)action=Check_Valid_Date;
    end
    else action=Make_drink;
    // else if (patcnt>200&&patcnt<=401) action=Check_Valid_Date;
    // else if(patcnt>601 &&patcnt<=1000)begin
    //     if (patcnt%2) begin
    //         action=Make_drink;
    //     end
    //     else action=Supply;
    // end
    // else if (patcnt>1000&&patcnt<=1400)begin
    //     if (patcnt%2) action=Make_drink;
    //     else action=Check_Valid_Date;
    // end
    // else if (patcnt>1400&&patcnt<=1799)begin
    //     if (patcnt%2) action=Supply;
    //     else action=Check_Valid_Date;
    // end
    // else begin
    //     action=Make_drink;
    // end
    // gap=$urandom_range(1, 4);
    gap=1;
    repeat(gap) @(negedge clk);
    inf.sel_action_valid=1;
    inf.D.d_act[0]=action;
    @(negedge clk);
    inf.sel_action_valid=0;
    inf.D='dx;
    case(action)
        Make_drink:maketask;
        Supply:supplytask;
        Check_Valid_Date:checktask;
    endcase
end
endtask
task maketask;begin
    case (makecnt%24)
        0:begin
            TYPE=Black_Tea;
            SIZE=L;
        end 
        1:begin
            TYPE=Black_Tea;
            SIZE=M;
        end
        2:begin
            TYPE=Black_Tea;
            SIZE=S;
        end
        3:begin
            TYPE=Green_Tea;
            SIZE=L;
        end 
        4:begin
            TYPE=Green_Tea;
            SIZE=M;
        end
        5:begin
            TYPE=Green_Tea;
            SIZE=S;
        end
        6:begin
            TYPE=Milk_Tea;
            SIZE=L;
        end 
        7:begin
            TYPE=Milk_Tea;
            SIZE=M;
        end
        8:begin
            TYPE=Milk_Tea;
            SIZE=S;
        end
        9:begin
            TYPE=Green_Milk_Tea;
            SIZE=L;
        end 
        10:begin
            TYPE=Green_Milk_Tea;
            SIZE=M;
        end
        11:begin
            TYPE=Green_Milk_Tea;
            SIZE=S;
        end
        12:begin
            TYPE=Extra_Milk_Tea;
            SIZE=L;
        end 
        13:begin
            TYPE=Extra_Milk_Tea;
            SIZE=M;
        end
        14:begin
            TYPE=Extra_Milk_Tea;
            SIZE=S;
        end
        15:begin
            TYPE=Pineapple_Juice;
            SIZE=L;
        end 
        16:begin
            TYPE=Pineapple_Juice;
            SIZE=M;
        end
        17:begin
            TYPE=Pineapple_Juice;
            SIZE=S;
        end
        18:begin
            TYPE=Super_Pineapple_Tea;
            SIZE=L;
        end 
        19:begin
            TYPE=Super_Pineapple_Tea;
            SIZE=M;
        end
        20:begin
            TYPE=Super_Pineapple_Tea;
            SIZE=S;
        end
        21:begin
            TYPE=Super_Pineapple_Milk_Tea;
            SIZE=L;
        end 
        22:begin
            TYPE=Super_Pineapple_Milk_Tea;
            SIZE=M;
        end
        23:begin
            TYPE=Super_Pineapple_Milk_Tea;
            SIZE=S;
        end
    endcase
    if (makecnt>=400) begin
        todaymonth=4'd12;
        todaydate=5'd31;
    end
    else begin
        random_month_date.randomize();
        todaymonth=random_month_date.todaymonth;
        todaydate=random_month_date.todaydate;
    end
    makecnt++;
    // random_type.randomize();
    // TYPE=random_type.TYPE;
    // random_size.randomize();
    // SIZE=random_size.SIZE;
    // random_month_date.randomize();
    // todaymonth=random_month_date.todaymonth;
    // todaydate=random_month_date.todaydate;
    // gap=$urandom_range(0, 3);
    gap=0;
    repeat(gap) @(negedge clk);
    inf.type_valid=1;
    inf.D.d_type[0]=TYPE;
    @(negedge clk);
    inf.type_valid=0;
    inf.D='dx;

    // gap=$urandom_range(0, 3);
    gap=0;
    repeat(gap) @(negedge clk);
    inf.size_valid=1;
    inf.D.d_size[0]=SIZE;
    @(negedge clk);
    inf.size_valid=0;
    inf.D='dx;

    // gap=$urandom_range(0, 3);
    gap=0;
    repeat(gap) @(negedge clk);
    inf.date_valid=1;
    inf.D.d_date[0]={todaymonth,todaydate};
    @(negedge clk);
    inf.date_valid=0;
    inf.D='dx;

    // gap=$urandom_range(0, 3);
    gap=0;
    repeat(gap) @(negedge clk);
    inf.box_no_valid=1;
    inf.D.d_box_no[0]=Boxnumber; 
    @(negedge clk);
    inf.box_no_valid=0;
    inf.D='dx;
end
endtask
task supplytask;begin
    random_month_date.randomize();
    todaymonth=random_month_date.todaymonth;
    todaydate=random_month_date.todaydate;
    random_sup_ing.randomize();
    supplying1=random_sup_ing.supplying1;
    supplying2=random_sup_ing.supplying2;
    supplying3=random_sup_ing.supplying3;
    supplying4=random_sup_ing.supplying4;

    // gap=$urandom_range(0, 3);
    gap=0;
    repeat(gap) @(negedge clk);
    inf.date_valid=1;
    inf.D.d_date[0]={todaymonth,todaydate};
    @(negedge clk);
    inf.date_valid=0;
    inf.D='dx;

    // gap=$urandom_range(0, 3);
    gap=0;
    repeat(gap) @(negedge clk);
    inf.box_no_valid=1;
    inf.D.d_box_no[0]=Boxnumber;
    @(negedge clk);
    inf.box_no_valid=0;
    inf.D='dx;

    // gap=$urandom_range(0, 3);
    gap=0;
    repeat(gap) @(negedge clk);
    inf.box_sup_valid=1;
    inf.D.d_ing[0]=supplying1;
    @(negedge clk);
    inf.box_sup_valid=0;
    inf.D='dx;

    // gap=$urandom_range(0, 3);
    gap=0;
    repeat(gap) @(negedge clk);
    inf.box_sup_valid=1;
    inf.D.d_ing[0]=supplying2;
    @(negedge clk);
    inf.box_sup_valid=0;
    inf.D='dx;

    // gap=$urandom_range(0, 3);
    gap=0;
    repeat(gap) @(negedge clk);
    inf.box_sup_valid=1;
    inf.D.d_ing[0]=supplying3;
    @(negedge clk);
    inf.box_sup_valid=0;
    inf.D='dx;

    // gap=$urandom_range(0, 3);
    gap=0;
    repeat(gap) @(negedge clk);
    inf.box_sup_valid=1;
    inf.D.d_ing[0]=supplying4;
    @(negedge clk);
    inf.box_sup_valid=0;
    inf.D='dx;
end
endtask

task checktask;begin
    random_month_date.randomize();
    todaymonth=random_month_date.todaymonth;
    todaydate=random_month_date.todaydate;

    // gap=$urandom_range(0, 3);
    gap=0;
    repeat(gap) @(negedge clk);
    inf.date_valid=1;
    inf.D.d_date[0]={todaymonth,todaydate};
    @(negedge clk);
    inf.date_valid=0;
    inf.D='dx;

    // gap=$urandom_range(0, 3);
    gap=0;
    repeat(gap) @(negedge clk);
    inf.box_no_valid=1;
    inf.D.d_box_no[0]=Boxnumber;
    @(negedge clk);
    inf.box_no_valid=0;
    inf.D='dx;
end
endtask

task makeans;begin
    b_tea_min=0;
    milk_min=0;
    g_tea_min=0;
    ppj_min=0;
    case(TYPE)
        Black_Tea: begin 
            case(SIZE)
                L: b_tea_min=960;
                M: b_tea_min=720;
                S: b_tea_min=480;
            endcase
        end
        Milk_Tea: begin
            case(SIZE)
                L: begin
                    b_tea_min=720;
                    milk_min=240;
                end
                M: begin
                    b_tea_min=540;
                    milk_min=180;
                end
                S: begin
                    b_tea_min=360;
                    milk_min=120;
                end
            endcase
        end
        Extra_Milk_Tea: begin
            case(SIZE)
                L: begin
                    b_tea_min=480;
                    milk_min=480;
                end
                M: begin
                    b_tea_min=360;
                    milk_min=360;
                end
                S: begin
                    b_tea_min=240;
                    milk_min=240;
                end
            endcase
        end
        Green_Tea: begin
            case(SIZE)
                L: g_tea_min=960;
                M: g_tea_min=720;
                S: g_tea_min=480;
            endcase
        end
        Green_Milk_Tea: begin
            case(SIZE)
                L: begin
                    g_tea_min=480;
                    milk_min=480;
                end
                M: begin
                    g_tea_min=360;
                    milk_min=360;
                end
                S: begin
                    g_tea_min=240;
                    milk_min=240;
                end
            endcase
        end
        Pineapple_Juice: begin
            case(SIZE)
                L: ppj_min=960;
                M: ppj_min=720;
                S: ppj_min=480;
            endcase
        end
        Super_Pineapple_Tea: begin
            case(SIZE)
                L: begin
                    b_tea_min=480;
                    ppj_min=480;
                end
                M: begin
                    b_tea_min=360;
                    ppj_min=360;
                end
                S: begin
                    b_tea_min=240;
                    ppj_min=240;
                end
            endcase
        end
        Super_Pineapple_Milk_Tea: begin
            case(SIZE)
                L: begin
                    b_tea_min=480;
                    milk_min=240;
                    ppj_min=240;
                end
                M: begin
                    b_tea_min=360;
                    milk_min=180;
                    ppj_min=180;
                end
                S: begin
                    b_tea_min=240;
                    milk_min=120;
                    ppj_min=120;
                end
            endcase
        end
    endcase
    if (tea.black_tea<b_tea_min) golden_err_msg=No_Ing;
    else if (tea.green_tea<g_tea_min) golden_err_msg=No_Ing;
    else if (tea.milk<milk_min) golden_err_msg=No_Ing;
    else if (tea.pineapple_juice<ppj_min) golden_err_msg=No_Ing;
    else golden_err_msg=No_Err;
    if (todaymonth>tea.M) golden_err_msg=No_Exp;
    else if (todaydate>tea.D&&todaymonth==tea.M) golden_err_msg=No_Exp;
end
endtask

task supplyans;begin
    bt_total=tea.black_tea+supplying1;
    gt_total=tea.green_tea+supplying2;
    m_total=tea.milk+supplying3;
    pj_total=tea.pineapple_juice+supplying4;
    if (bt_total[12]||gt_total[12]||m_total[12]||pj_total[12]) golden_err_msg=Ing_OF;
    else golden_err_msg=No_Err;
end
endtask

task checkans;begin
    if (todaymonth>tea.M) golden_err_msg=No_Exp;
    else if (todaydate>tea.D&&todaymonth==tea.M) golden_err_msg=No_Exp;
    else golden_err_msg=No_Err;
end
endtask

task wait_out_valid_task; begin
    latency = 0;
    while(inf.out_valid !== 1) begin
        latency = latency + 1;
        @(negedge clk);
    end
end
endtask

task checkoutputtask;begin
    golden_complete=0;
    golden_err_msg=No_Err;
    case(action)
        Make_drink:makeans;
        Supply:supplyans;
        Check_Valid_Date:checkans;
    endcase
    golden_complete=!golden_err_msg;
    if(inf.err_msg !== golden_err_msg || inf.complete !== golden_complete) begin
        $display("*************************************************************************");     
        $display("*                               Wrong Answer                            *");
        $display("*                      golden_err_msg: %b  yours: %b                    *", golden_err_msg, inf.err_msg);
        $display("*                      golden_complete: %b  yours: %b                   *", golden_complete, inf.complete);
        $display("*************************************************************************");
        $finish;
    end
end
endtask

task makedramans;begin
    if (golden_err_msg==No_Err) begin
        tea.black_tea=tea.black_tea-b_tea_min;
        tea.green_tea=tea.green_tea-g_tea_min;
        tea.milk=tea.milk-milk_min;
        tea.pineapple_juice=tea.pineapple_juice-ppj_min;
    end
end
endtask

task supdramans;begin
    if (bt_total[12]) tea.black_tea=4095;
    else tea.black_tea=bt_total;
    if (gt_total[12]) tea.green_tea=4095;
    else tea.green_tea=gt_total;
    if (m_total[12]) tea.milk=4095;
    else tea.milk=m_total;
    if (pj_total[12]) tea.pineapple_juice=4095;
    else tea.pineapple_juice=pj_total;
    tea.M=todaymonth;
    tea.D=todaydate;
end
endtask

task storetask;begin
    case (action)
        Make_drink:makedramans;
        Supply:supdramans;
    endcase
    {golden_DRAM[(65536 + Boxnumber*8 + 7)], golden_DRAM[(65536 + Boxnumber*8 + 6)][7:4]} = tea.black_tea;
    {golden_DRAM[(65536 + Boxnumber*8 + 6)][3:0], golden_DRAM[(65536 + Boxnumber*8 + 5)]} = tea.green_tea;
    {golden_DRAM[(65536 + Boxnumber*8 + 4)][3:0]}                                      = tea.M;
    {golden_DRAM[(65536 + Boxnumber*8 + 3)], golden_DRAM[(65536 + Boxnumber*8 + 2)][7:4]} = tea.milk;
    {golden_DRAM[(65536 + Boxnumber*8 + 2)][3:0], golden_DRAM[(65536 + Boxnumber*8 + 1)]} = tea.pineapple_juice;
    {golden_DRAM[(65536 + Boxnumber*8 + 0)][4:0]}                                      = tea.D;
end
endtask
task youpasstask; begin
    $display("*************************************************************************");
    $display("*                            Congratulations                            *");
    $display("*                   Your execution cycles = %5d cycles               *", tot_lat);
    $display("*************************************************************************");
    $finish;
end endtask



endprogram

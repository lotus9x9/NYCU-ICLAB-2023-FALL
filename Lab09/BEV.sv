module BEV(input clk, INF.BEV_inf inf);
import usertype::*;

typedef enum logic [2:0]{
    IDLE,
    INPUT,
    WAITFORDRAM,
    CHECK,
    CAL,
    DONOTHING,
    WRITEDRAM
} FSM;

FSM state,nextstate;
logic [1:0]action;
logic [2:0] TYPE;
logic[1:0] SIZE;
logic [3:0]todaymonth;
logic [4:0]todaydate;
logic [7:0]Boxnumber;
Bev_Bal tea;
logic [9:0]b_tea_min,milk_min,g_tea_min,ppj_min;
logic [11:0]supplying[0:3];
logic [12:0]bt_total,gt_total,m_total,pj_total;
logic [1:0]cnt4;
logic complete;
Error_Msg errmsg;
// ===============================================================
//  					    FSM 
// ===============================================================
always_ff @( posedge clk or negedge inf.rst_n ) begin
    if (!inf.rst_n) begin
        state<=IDLE;
    end
    else state<=nextstate;
end
always_comb begin
    case (state)
        IDLE:begin
            if (inf.sel_action_valid) nextstate=INPUT;
            else nextstate=IDLE;
        end 
        INPUT:begin
            if (action==2'b01) begin
                if (inf.box_sup_valid&&cnt4==3) nextstate=WAITFORDRAM;
                else nextstate=INPUT;
            end
            else begin
                if(inf.box_no_valid) nextstate=WAITFORDRAM;
                else nextstate=INPUT;
            end
        end
        WAITFORDRAM:begin
            if (action==1) begin
                if (inf.C_out_valid) nextstate=CAL;
                else nextstate=WAITFORDRAM;
            end
            else begin
                if (inf.C_out_valid) nextstate=CHECK;
                else nextstate=WAITFORDRAM;
            end
        end
        CHECK:begin
           if (action==0) nextstate=CAL;
           else nextstate=WRITEDRAM;
        end
        CAL:begin
            if (action==0&&errmsg!=0) nextstate=WRITEDRAM;
            else nextstate=DONOTHING;
        end
        DONOTHING:nextstate=WRITEDRAM;
        WRITEDRAM:begin
            if (action==2) nextstate=IDLE;
            else if (action==0&&errmsg!=0) nextstate=IDLE;
            else if (inf.C_out_valid) nextstate=IDLE;
            else nextstate=WRITEDRAM;
        end
        default:nextstate=IDLE; 
    endcase
end
// ===============================================================
//  					Input / Output 
// ===============================================================
always_ff@(posedge clk or negedge inf.rst_n)begin
    if (!inf.rst_n) begin
        action<=0;
    end
    else if (inf.sel_action_valid) action<=inf.D.d_act[0];
end
always_ff@(posedge clk or negedge inf.rst_n)begin
    if (!inf.rst_n) begin
        TYPE<=0;
    end
    else if (inf.type_valid) TYPE<=inf.D.d_type[0];
end
always_ff@(posedge clk or negedge inf.rst_n)begin
    if (!inf.rst_n) begin
        SIZE<=0;
    end
    else if (inf.size_valid) SIZE<=inf.D.d_size[0];
end
always_ff @( posedge clk or negedge inf.rst_n ) begin
    if (!inf.rst_n) begin
        todaymonth<=0;
    end
    else if(inf.date_valid) todaymonth<=inf.D.d_date[0][8:5];
end
always_ff @( posedge clk or negedge inf.rst_n ) begin 
    if (!inf.rst_n) begin
        todaydate<=0;
    end
    else if(inf.date_valid) todaydate<=inf.D.d_date[0][4:0];
end
always_ff @( posedge clk or negedge inf.rst_n ) begin
    if (!inf.rst_n) begin
        Boxnumber<=0;
    end
    else if(inf.box_no_valid)Boxnumber<=inf.D.d_box_no[0];
end
always_ff @( posedge clk or negedge inf.rst_n ) begin 
    if (!inf.rst_n) cnt4<=0;
    else if (inf.box_sup_valid) begin
        cnt4<=cnt4+1;
    end
    else if (inf.out_valid) begin
        cnt4<=0;
    end
end
always_ff @( posedge clk or negedge inf.rst_n ) begin
    if (!inf.rst_n) begin
        for (integer i=0 ;i<4 ;i=i+1 ) begin
            supplying[i]<=0;
        end
    end
    else if (inf.box_sup_valid) supplying[cnt4]<=inf.D.d_ing[0];
end
// ===============================================================
//  					    DRAM CTRL 
// ===============================================================
always_comb begin
    inf.C_addr=Boxnumber;
end
always_ff @( posedge clk or negedge inf.rst_n ) begin
    if (!inf.rst_n) begin
        inf.C_r_wb<=0;
    end
    else begin
        if (state==DONOTHING) begin
            inf.C_r_wb<=0;
        end
        else inf.C_r_wb<=1;
    end
end
// always_comb begin 
//     if (!inf.rst_n) inf.C_r_wb=0;
//     else if (state==WRITEDRAM) begin
//         inf.C_r_wb=0;
//     end
//     else inf.C_r_wb=1;
// end
always_ff @( posedge clk or negedge inf.rst_n ) begin
    if (!inf.rst_n) begin
        inf.C_in_valid<=0;
    end    
    else begin
        if (state==INPUT&&nextstate==WAITFORDRAM) begin
            inf.C_in_valid<=1;
        end
        else if (state==DONOTHING) begin
            inf.C_in_valid<=1;
        end
        else inf.C_in_valid<=0;
    end
end
always_comb begin 
    inf.C_data_w={tea.black_tea,tea.green_tea,4'b0,tea.M,tea.milk,tea.pineapple_juice,3'b0,tea.D};
end
// ===============================================================
//  					    MAKE CAL 
// ===============================================================
always_comb begin 
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
end
always_ff @(posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n) begin
        tea.black_tea<=0;
        tea.green_tea<=0;
        tea.milk<=0;
        tea.pineapple_juice<=0;
        tea.M<=0;
        tea.D<=0;
    end
    else if(inf.C_out_valid)begin
        tea.black_tea<=inf.C_data_r[63:52];
        tea.green_tea<=inf.C_data_r[51:40];
        tea.M<=inf.C_data_r[35:32];
        tea.milk<=inf.C_data_r[31:20];
        tea.pineapple_juice<=inf.C_data_r[19:8];
        tea.D<=inf.C_data_r[4:0];
    end
    else if (state==CAL&&errmsg==0&&action==0) begin
        tea.black_tea<=tea.black_tea-b_tea_min;
        tea.green_tea<=tea.green_tea-g_tea_min;
        tea.milk<=tea.milk-milk_min;
        tea.pineapple_juice<=tea.pineapple_juice-ppj_min;
    end
    else if (state==CAL&&action==1) begin
        if (bt_total[12]) tea.black_tea<=4095;
        else tea.black_tea<=bt_total;
        if (gt_total[12]) tea.green_tea<=4095;
        else tea.green_tea<=gt_total;
        if (m_total[12]) tea.milk<=4095;
        else tea.milk<=m_total;
        if (pj_total[12]) tea.pineapple_juice<=4095;
        else tea.pineapple_juice<=pj_total;
        tea.M<=todaymonth;
        tea.D<=todaydate;
    end
end
// ===============================================================
//  					    SUPPLY CAL 
// ===============================================================
always_comb begin 
    bt_total=tea.black_tea+supplying[0];
    gt_total=tea.green_tea+supplying[1];
    m_total=tea.milk+supplying[2];
    pj_total=tea.pineapple_juice+supplying[3];
end
// ===============================================================
//  					   ERROR MESSAGE
// ===============================================================
always_ff @( posedge clk or negedge inf.rst_n ) begin 
    if (!inf.rst_n) begin
        errmsg<=No_Err;
    end
    else begin
        if (state==CHECK&&action==0) begin
            if (tea.black_tea<b_tea_min) errmsg<=No_Ing;
            else if (tea.green_tea<g_tea_min) errmsg<=No_Ing;
            else if (tea.milk<milk_min) errmsg<=No_Ing;
            else if (tea.pineapple_juice<ppj_min) errmsg<=No_Ing;
            else errmsg<=No_Err;
            if (todaymonth>tea.M) errmsg<=No_Exp;
            else if (todaydate>tea.D&&todaymonth==tea.M) errmsg<=No_Exp;
        end
        else if (state==CHECK&&action==2) begin
            if (todaymonth>tea.M) errmsg<=No_Exp;
            else if (todaydate>tea.D&&todaymonth==tea.M) errmsg<=No_Exp;
            else errmsg<=No_Err;
        end
        else if (state==CAL&&action==1) begin
            if (bt_total[12]||gt_total[12]||m_total[12]||pj_total[12]) errmsg<=Ing_OF;
            else errmsg<=No_Err;
        end
    end
end
// ===============================================================
//  					    OUTPUT 
// ===============================================================
assign complete=!errmsg;
always_ff @( posedge clk or negedge inf.rst_n ) begin
    if (!inf.rst_n) begin
        inf.out_valid<=0;
    end
    else if ((state==WRITEDRAM&&action==2)||(inf.C_out_valid&&state==WRITEDRAM)||(state==WRITEDRAM&&action==0&&errmsg!=0)) inf.out_valid<=1;
    else inf.out_valid<=0;
end
always_ff @( posedge clk or negedge inf.rst_n ) begin 
    if (!inf.rst_n) begin
        inf.complete<=0;
    end
    else if (((state==WRITEDRAM&&action==2)||(inf.C_out_valid&&state==WRITEDRAM)||(state==WRITEDRAM&&action==0&&errmsg!=0))) begin
        inf.complete<=complete;
    end
    else inf.complete<=0;
end
always_ff @( posedge clk or negedge inf.rst_n ) begin 
    if (!inf.rst_n) begin
        inf.err_msg<=No_Err;
    end
    else if ((state==WRITEDRAM&&action==2)||(inf.C_out_valid&&state==WRITEDRAM)||(state==WRITEDRAM&&action==0&&errmsg!=0)) begin
        inf.err_msg<=errmsg;
    end
    else inf.err_msg<=No_Err;
end
endmodule
module CC(
    //Input Port
    clk,
    rst_n,
	in_valid,
	mode,
    xi,
    yi,

    //Output Port
    out_valid,
	xo,
	yo
    );

input               clk, rst_n, in_valid; 
input       [1:0]   mode;
input signed [7:0]   xi, yi;  

output reg          out_valid;
output reg signed [7:0]   xo, yo;
//==============================================//
//             Parameter and Integer            //
//==============================================//
parameter idle=2'd0;
parameter Input=2'd1;
parameter modestate=2'd2;
parameter out=2'd3;
reg [1:0]state,nextstate;
reg [1:0]modereg;
reg signed [7:0]x[0:3];
reg signed [7:0]y[0:3];
reg signed [7:0]x_left,x_right,x_new_right,x_tmp_left,x_tmp_right;
reg signed[15:0]tmptmp,ctmp;
reg signed[8:0]atmp,btmp;
reg [1:0]count;
reg signed[7:0]bound;
reg signed [7:0]x1tmp,x2tmp,y1tmp,y2tmp;
reg signed [6:0] a,b;
reg signed[11:0]c;
reg [11:0]caltmp5,caltmp6;
reg signed [11:0]caltmp3;
reg signed [12:0]caltmp4;
reg signed [13:0]caltmp7;
reg signed [15:0]caltmp1,caltmp2;
reg signed [12:0]caltmp8;
reg signed [7:0]yotmp;
reg signed [16:0]tmparea;
reg signed [15:0]tmp;
reg [14:0]area;
reg [23:0]linetocircle;
reg [23:0]radius;
reg cmp;
reg signed [7:0]xtmp,ytmp;
/*Input*/
always @(posedge clk) begin
    if (in_valid) begin
        x[count]<=xi;
        y[count]<=yi;
        count<=count+1;
        modereg<=mode;
    end
    else count<=0;
end
/*Output*/
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        state<=idle;
        xo<=8'd0;
        yo<=8'd0;
    end
    else begin
        state<=nextstate;
        if (state==out) begin
            case (modereg)
                2'd0:begin
                    if (xo==x_new_right) begin
                        xo<=x_left;
                        yo<=yo+1;
                        x_new_right<=x_right;
                    end
                    else begin
                        yo<=yo;
                        xo<=xo+1;
                    end 
                end
            endcase
        end
        else begin
            x_new_right<=x[3];
            case (modereg)
                2'd0:begin
                    xo<=x[2];
                    yo<=y[2];
                end 
                2'd1:begin
                    xo<=8'd0;
                    yo<=yotmp;
                end
                2'd2:begin
                    xo<=area[14:8];
                    yo<=area[7:0];
                end
            endcase
        end
    end
end
/*FSM*/
always @(*) begin
    case (state)
        idle:nextstate=in_valid?Input:idle;
        Input:begin
            if ((count==3)) nextstate=modestate;
            else nextstate=Input;
        end
        modestate:nextstate=out;
        out:begin
            case (modereg)
                2'd0:begin
                    if ((xo==x[1])&&(yo==y[1])) nextstate=idle;               
                    else nextstate=out;
                end
                default: nextstate=idle;
            endcase
        end    
    endcase
end
/*Calculate for mode_1 and mode_2*/
always @(*) begin
    a=y[0]-y[1];
    b=x[1]-x[0];
    caltmp1=x[0]*y[1];
    caltmp2=x[1]*((modereg==1)?y[0]:y[2]);
    caltmp3=(x[3]-x[2])*(x[3]-x[2]);
    caltmp4=(y[3]-y[2])*(y[3]-y[2]);
    caltmp5=a*a;
    caltmp6=b*b;
    c=caltmp1-caltmp2;
    caltmp7=caltmp5+caltmp6;
    radius=(caltmp3+caltmp4)*caltmp7;
    caltmp8=a*x[2]+b*y[2]+c;
    linetocircle=caltmp8*caltmp8;
    if (linetocircle==radius) yotmp=8'd2;
    else if (linetocircle<=radius) yotmp=8'd1;
    else yotmp=8'd0;
    caltmp5=a*a;
    caltmp6=b*b;
    caltmp7=caltmp5+caltmp6;
    c=caltmp1-caltmp2;
    radius=(caltmp3+caltmp4)*caltmp7;
    tmparea=caltmp1+caltmp2+x[2]*y[3]+x[3]*y[0]-y[0]*x[1]-y[1]*x[2]-y[2]*x[3]-y[3]*x[0];
    if (tmparea[16]==0) tmp=tmparea;
    else tmp=-tmparea;
    area=tmp>>1;
end
/*Calculate for mode_0*/
always @(*) begin
    {x1tmp,x2tmp,y1tmp,y2tmp}=(xo==x_new_right)?{x[1],x[3],y[1],y[3]}:{x[0],x[2],y[0],y[2]};
    cmp=x1tmp>=x2tmp;
    atmp=x1tmp-x2tmp;
    btmp=y1tmp-y2tmp;
    xtmp=cmp?x2tmp:x1tmp;
    ytmp=cmp?y2tmp:y1tmp;
    bound=xtmp+((yo+1-ytmp)*atmp/btmp);
end
/*out_valid*/
always @(*) begin
    case (state)
        out:out_valid=1'b1;
        default: out_valid=1'b0;
    endcase
end
/*x_left*/
always @(posedge clk) begin
    if (xo!=x_new_right) x_left<=bound;
end
/*x_right*/
always @(*) begin
    if (xo==x_new_right) x_right=bound;
    else x_right=8'd0;
end
endmodule
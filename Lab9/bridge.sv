module bridge(input clk, INF.bridge_inf inf);

//================================================================
// logic 
//================================================================
logic [63:0] data_w_reg;
logic   C_out_valid_ns;
logic [7:0] addr;
typedef enum logic [2:0] {IN,ARREADY,READREADY,AWREADY,WRITEREADY,OUT} FSM;
FSM state;
FSM nextstate;

//================================================================
// design 
//================================================================

always_comb begin
    nextstate=state;
    inf.AR_VALID=0;
    if (state == IN)begin
        inf.AR_ADDR=0;
        inf.AW_ADDR=0;
        inf.W_DATA=0;
    end
    else begin
      inf.AR_ADDR=addr * 8 + 65536;
      inf.AW_ADDR=addr * 8 + 65536;
      inf.W_DATA=data_w_reg;
    end
    inf.R_READY=0;
    inf.AW_VALID=0;
    inf.W_VALID=0;
    inf.B_READY=0;
    C_out_valid_ns=0;
    inf.C_data_r=0;
    if (inf.C_out_valid)inf.C_data_r=data_w_reg;
    case (state)
      IN:begin
        if (inf.C_in_valid)begin
          if (inf.C_r_wb)nextstate=ARREADY;
          else nextstate=AWREADY;
        end
      end
      ARREADY:begin
        inf.AR_VALID=1;
        if (inf.AR_READY)nextstate=READREADY;
      end
      READREADY:begin
        inf.R_READY=1;
        if (inf.R_VALID)begin
          C_out_valid_ns=1;
          nextstate=OUT;
        end
      end
      AWREADY:begin
        inf.AW_VALID=1;
        if (inf.AW_READY)nextstate=WRITEREADY;
      end
      WRITEREADY:begin
        inf.W_VALID=1;
        inf.B_READY=1;
        if (inf.B_VALID)begin
          C_out_valid_ns=1;
          nextstate=OUT;
        end
      end
      OUT:nextstate=IN;
    endcase
end

always_ff @ (posedge clk or negedge inf.rst_n)begin
  if (!inf.rst_n)data_w_reg <= 0;
  else if (inf.R_VALID)data_w_reg <= inf.R_DATA;
  else if (!inf.C_r_wb)data_w_reg <= inf.C_data_w;
end

always_ff @ (posedge clk or negedge inf.rst_n) begin
  if (!inf.rst_n)begin
    state <= IN;
    addr <= 0;
    inf.C_out_valid <= 0;
  end
  else begin
    state <= nextstate;
    addr <= inf.C_addr;
    inf.C_out_valid <= C_out_valid_ns;
  end
end
endmodule
////////////////////////////////////////////////////////////
// File Description: This file is instruction fetch top
// Date:   2019.09.18
// Description: Peak is one mcu core aims to compete with
// Cortex-M4 or Cortex-M33
// The frequency should be higer so there is no data bypass
// currently, we have 4*16 bits buffer between ifu and dpu
// if it is not enough, we can enlarge when we start to tune
// This file only has interface with memory, which is flexible
// to add icache controler, itcm or just main memory
// Define is not good, so we only have localparam
///////////////////////////////////////////////////////////
module peak_ifu
(
rst_n,
clk,
imem_ifu_req_ack,
ifu_imem_req,
ifu_imem_addr,
imem_ifu_rdata,
imem_ifu_resp,
dpu_ifu_new_pc_req,
dpu_ifu_new_pc,
dpu_ifu_stop_fetch,
ifu_dpu_imem_txns_pending,
dpu2ifu_rdy,
ifu2dpu_instr,
ifu2dpu_imem_err,
ifu2dpu_err_rvi_hi,
ifu2dpu_vd
);

// Control signals
input         rst_n;
input         clk;
// Instruction memory interface
input         imem_ifu_req_ack;
output        ifu_imem_req;
output[31:0]  ifu_imem_addr;
input[31:0]   imem_ifu_rdata;
input[1:0]    imem_ifu_resp;
// NEW_PC interface
input         dpu_ifu_new_pc_req;
input[31:0]   dpu_ifu_new_pc;
input         dpu_ifu_stop_fetch;// Stop IFU
output        ifu_dpu_imem_txns_pending;  // There are pending imem transactions
// Instruction decode unit interface
input         dpu2ifu_rdy;// IDU ready for new data
output[31:0]  ifu2dpu_instr;// IFU instruction
output        ifu2dpu_imem_err; // Instruction access fault exception
output        ifu2dpu_err_rvi_hi;// 1 - imem fault when trying to fetch second half of an unaligned RVI instruction
output[1:0]   ifu2dpu_vd;// IFU request

//-------------------------------------------------------------------------------
// Local parameters declaration
//-------------------------------------------------------------------------------

localparam PEAK_IFU_Q_SIZE_WORD     = 2;
localparam PEAK_IFU_Q_SIZE_HALF     = PEAK_IFU_Q_SIZE_WORD * 2;
localparam PEAK_TXN_CNT_W           = 3;

localparam PEAK_IFU_QUEUE_ADR_W     = $clog2(PEAK_IFU_Q_SIZE_HALF);
localparam PEAK_IFU_QUEUE_PTR_W     = PEAK_IFU_QUEUE_ADR_W + 1;

localparam PEAK_IFU_Q_FREE_H_W      = $clog2(PEAK_IFU_Q_SIZE_HALF + 1);
localparam PEAK_IFU_Q_FREE_W_W      = $clog2(PEAK_IFU_Q_SIZE_WORD + 1);

localparam PEAK_FSM_IDLE            = 1'b0;
localparam PEAK_FSM_FETCH           = 1'b1;

localparam PEAK_WR_NONE             = 2'h0; // No write to queue
localparam PEAK_WE_RDATA_FULL       = 2'h1; // Write 32 rdata bits to queue
localparam PEAK_WE_RDATA_HI         = 2'h2; // Write 16 upper rdata bits to queue

localparam PEAK_RE_NONE             = 2'h0; // No queue read
localparam PEAK_RE_HALFWORD         = 2'h1; // Read halfword
localparam PEAK_RE_WORD             = 2'h2; // Read word

localparam PEAK_RVI_PART2           = 1'b0; // Rdata has RVI upper 16 bits in its lower 16 bits
localparam PEAK_OTHER               = 1'b1;

localparam PEAK_RDATA_NONE             = 3'h0; // No valid rdata
localparam PEAK_RDATA_RVI_HI_RVI_LO    = 3'h1; // Full RV32I instruction
localparam PEAK_RDATA_RVC_RVC          = 3'h2;                                 
localparam PEAK_RDATA_RVI_LO_RVC       = 3'h3;                                 
localparam PEAK_RDATA_RVC_RVI_HI       = 3'h4;                                 
localparam PEAK_RDATA_RVI_LO_RVI_HI    = 3'h5;                                 
localparam PEAK_RDATA_RVC_NV           = 3'h6; // Rdata after unaligned new_pc                                
localparam PEAK_RDATA_RVI_LO_NV        = 3'h7; // Rdata after unaligned new_pc
                                               

//-------------------------------------------------------------------------------
// Local signals declaration
//-------------------------------------------------------------------------------

reg                         fsm;
reg [31:2]                  imem_addr_r;
wire[31:2]                  imem_addr_r_new;
reg[PEAK_TXN_CNT_W-1:0]     num_txns_pending;// Transactions sent but not yet returned
wire[PEAK_TXN_CNT_W-1:0]    num_txns_pending_new;
reg[PEAK_TXN_CNT_W-1:0]     discard_resp_cnt;// Number of imem responses to discard
wire[PEAK_TXN_CNT_W-1:0]    discard_resp_cnt_new;
wire                        discard_resp;
wire[PEAK_TXN_CNT_W-1:0]    num_vd_txns_pending;
wire                        num_txns_pending_full;
wire                        imem_resp_ok;
wire                        imem_resp_er;
wire                        imem_resp_vd;
reg                         new_pc_unaligned;

wire                             q_empty;
wire                             q_flush;
reg[PEAK_IFU_QUEUE_PTR_W-1:0]    q_rptr;
wire[PEAK_IFU_QUEUE_PTR_W-1:0]   q_rptr_next;
reg[PEAK_IFU_QUEUE_PTR_W-1:0]    q_wptr;
wire[PEAK_IFU_QUEUE_PTR_W-1:0]   q_wptr_next;
wire[PEAK_IFU_Q_FREE_H_W-1:0]    q_ocpd_h;// Queue occupied halfwords
wire[PEAK_IFU_Q_FREE_H_W-1:0]    q_free_h_next;
wire[PEAK_IFU_Q_FREE_W_W-1:0]    q_free_w_next;// Used for imem_req logic

reg[15:0]  q_data0;
reg[15:0]  q_data1;
reg[15:0]  q_data2;
reg[15:0]  q_data3;
reg        q_err0;
reg        q_err1;
reg        q_err2;
reg        q_err3;

wire[1:0]  q_re;// Queue read
wire[1:0]  q_we;// Queue write
wire       q_head_rvc;// RVC instruction at read pointer
wire       q_head_rvi;// RVI instruction at read pointer
wire[15:0] q_data_head;
wire[15:0] q_data_next;
wire       q_err_head;
wire       q_err_next;

reg   rdata_curr;
wire  rdata_next;
reg[2:0] rdata_ident;// Identifies contents of rdata


//-------------------------------------------------------------------------------
// Instruction queue logic
//-------------------------------------------------------------------------------
assign q_empty          = (q_rptr == q_wptr);
assign q_flush          = new_pc_req | stop_fetch;

assign q_ocpd_h         = PEAK_IFU_Q_FREE_H_W'(q_wptr - q_rptr);
assign q_free_h_next    = PEAK_IFU_Q_FREE_H_W'(PEAK_IFU_Q_SIZE_HALF - (q_wptr - q_rptr_next));
assign q_free_w_next    = PEAK_IFU_Q_FREE_W_W'(q_free_h_next >> 1'b1);

assign q_head_rvi       = &(q_data_head[1:0]);
assign q_head_rvc       = ~q_head_rvi;
assign q_snd_rvc        = ~(&q_data_next[1:0]);

assign q_data_head      = q_data [PEAK_IFU_QUEUE_ADR_W'(q_rptr)];
assign q_data_next      = q_data [PEAK_IFU_QUEUE_ADR_W'(q_rptr + 1'b1)];
assign q_err_head       = q_err  [PEAK_IFU_QUEUE_ADR_W'(q_rptr)];
assign q_err_next       = q_err  [PEAK_IFU_QUEUE_ADR_W'(q_rptr + 1'b1)];


always @ (*) begin
    q_re = PEAK_RE_NONE;

    if (~q_empty & ifu2dpu_vd & dpu2ifu_rdy) begin
        if (q_head_rvc | q_err_head) begin
            q_re = PEAK_RE_HALFWORD;
        end else begin
            q_re = PEAK_RE_WORD;
        end
    end
end

always @ (*) begin
    q_we = PEAK_WE_NONE;

    if (~discard_resp) begin
        if (imem_resp_ok) begin
            case (rdata_ident)
                PEAK_RDATA_NONE             : q_we = PEAK_WE_NONE;
                PEAK_RDATA_RVC_NV,
                PEAK_RDATA_RVI_LO_NV        : q_we = PEAK_WE_RDATA_HI;
                default                     : q_we = PEAK_WE_RDATA_FULL;
            endcase // rdata_ident
        end else if (imem_resp_er) begin
            q_we = PEAK_WE_RDATA_FULL;
        end // imem_resp_er
    end // ~discard_resp
end

always @ (*) begin
    q_rptr_next = q_rptr;
    q_wptr_next = q_wptr;

    if ((q_we == PEAK_WE_RDATA_HI) | (q_we == PEAK_WE_RDATA_FULL)) begin
        q_wptr_next = q_wptr + ((q_we == PEAK_WE_RDATA_FULL) ? 2'd2 : 1'b1);
    end
    if ((q_re == PEAK_RE_WORD) | (q_re == PEAK_RE_HALFWORD)) begin
        q_rptr_next = q_rptr + ((q_re == PEAK_RE_WORD) ? 2'd2 : 1'b1);
    end
end

always @ (posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        q_rptr  <= 'h0;
        q_wptr  <= 'h0;
    end else begin
        if (q_flush) begin
            q_rptr  <= 'h0;
            q_wptr  <= 'h0;
        end else begin
            if ((q_we == PEAK_WE_RDATA_HI) | (q_we == PEAK_WE_RDATA_FULL)) begin
                q_wptr  <= q_wptr_next;
            end
            if ((q_re == PEAK_RE_WORD) | (q_re == PEAK_RE_HALFWORD)) begin
                q_rptr  <= q_rptr_next;
            end
        end
    end
end

wire q_data0_sel_lo = ((q_we == 2'h2) & (q_wptr == 2'h0));
wire q_data0_sel_hi = ((q_we == 2'h1) & (q_wptr == 2'h0)) ||
	              ((q_we == 2'h2) & (q_wptr == 2'h3));

wire q_data0_we = q_data0_sel_lo |
	          q_data0_sel_hi;

always @ (posedge clk) begin
    if(q_data0_we) begin
        q_data0 <= q_data0_sel_lo ? imem_rdata[15:0] : imem_rdata[31:16];
	q_err0  <= imem_resp_er;
    end
end

wire q_data1_sel_lo = ((q_we == 2'h2) & (q_wptr == 2'h1));
wire q_data1_sel_hi = ((q_we == 2'h1) & (q_wptr == 2'h1)) ||
	              ((q_we == 2'h2) & (q_wptr == 2'h0));

wire q_data1_we = q_data1_sel_lo |
	          q_data1_sel_hi;

always @ (posedge clk) begin
    if(q_data1_we) begin
        q_data1 <= q_data1_sel_lo ? imem_rdata[15:0] : imem_rdata[31:16];
	q_err1  <= imem_resp_er;
    end
end

wire q_data2_sel_lo = ((q_we == 2'h2) & (q_wptr == 2'h2));
wire q_data2_sel_hi = ((q_we == 2'h1) & (q_wptr == 2'h2)) ||
	              ((q_we == 2'h2) & (q_wptr == 2'h1));

wire q_data2_we = q_data2_sel_lo |
	          q_data2_sel_hi;

always @ (posedge clk) begin
    if(q_data2_we) begin
        q_data2 <= q_data2_sel_lo ? imem_rdata[15:0] : imem_rdata[31:16];
	q_err2  <= imem_resp_er;
    end
end

wire q_data3_sel_lo = ((q_we == 2'h2) & (q_wptr == 2'h3));
wire q_data3_sel_hi = ((q_we == 2'h1) & (q_wptr == 2'h3)) ||
	              ((q_we == 2'h2) & (q_wptr == 2'h2));

wire q_data3_we = q_data3_sel_lo |
	          q_data3_sel_hi;

always @ (posedge clk) begin
    if(q_data3_we) begin
        q_data3 <= q_data3_sel_lo ? imem_rdata[15:0] : imem_rdata[31:16];
	q_err3  <= imem_resp_er;
    end
end
	              
//-------------------------------------------------------------------------------
// RDATA logic
//-------------------------------------------------------------------------------
always @ (*) begin
    rdata_ident = PEAK_RDATA_NONE;

    if (imem_resp_ok & ~discard_resp) begin
        if (new_pc_unaligned) begin
            if (&imem_rdata[17:16]) begin
                rdata_ident = PEAK_RDATA_RVI_LO_NV;
            end else begin
                rdata_ident = PEAK_RDATA_RVC_NV;
            end
        end else begin // ~new_pc_unaligned
            if (rdata_curr == PEAK_RVI_PART2) begin
                if (&imem_rdata[17:16]) begin
                    rdata_ident = PEAK_RDATA_RVI_LO_RVI_HI;
                end else begin
                    rdata_ident = PEAK_RDATA_RVC_RVI_HI;
                end
            end else begin // PEAK_OTHER
                casez ({&imem_rdata[17:16], &imem_rdata[1:0]})
                    2'b?1   : rdata_ident   = PEAK_RDATA_RVI_HI_RVI_LO;
                    2'b00   : rdata_ident   = PEAK_RDATA_RVC_RVC;
                    2'b10   : rdata_ident   = PEAK_RDATA_RVI_LO_RVC;
                endcase
            end // PEAK_OTHER
        end // ~new_pc_unaligned
    end // (imem_resp_ok & ~discard_resp)
end

assign rdata_next   =   ( (rdata_ident == PEAK_RDATA_RVI_LO_NV)
                        | (rdata_ident == PEAK_RDATA_RVI_LO_RVI_HI)
                        | (rdata_ident == PEAK_RDATA_RVI_LO_RVC) ) ? PEAK_RVI_PART2 : PEAK_OTHER;

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        rdata_curr  <= PEAK_OTHER;
    end else begin
        if (new_pc_req) begin
            rdata_curr  <= PEAK_OTHER;
        end else if (imem_resp_vd) begin
            rdata_curr  <= rdata_next;
        end
    end
end


//-------------------------------------------------------------------------------
// Instruction memory interface logic
//-------------------------------------------------------------------------------

assign imem_req = (new_pc_req & ~num_txns_pending_full & ~stop_fetch) |
(
    (fsm == PEAK_FSM_FETCH) &
    ~num_txns_pending_full &
    (PEAK_TXN_CNT_W'(q_free_w_next) > num_vd_txns_pending)
);

assign imem_addr                = {(new_pc_req ? new_pc[31:2] : imem_addr_r), 2'b00};

assign imem_resp_er             = (imem_resp == PEAK_MEM_RESP_RDY_ER);
assign imem_resp_ok             = (imem_resp == PEAK_MEM_RESP_RDY_OK);
assign imem_resp_vd             = (imem_resp_ok | imem_resp_er) & ~discard_resp;
//modify by hao.sun 2019.08.05
//assign num_txns_pending_full    = &num_txns_pending;
assign num_txns_pending_full    = &num_txns_pending & 
                                  ~imem_resp_vd; //can fetch back2back
//modify end

assign imem_txns_pending        = |num_txns_pending;

assign imem_addr_r_new = (new_pc_req ? new_pc[31:2] : imem_addr_r) + 1'b1;

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        imem_addr_r <= 30'h0;
    end else begin
        if (imem_req & imem_req_ack) begin
            // if req & ack, store either incremented new_pc or incremented address
            if (new_pc_req) begin
                imem_addr_r <= imem_addr_r_new;
            end else begin
                imem_addr_r[5:2] <= imem_addr_r_new[5:2];
                if (&imem_addr_r[5:2]) begin
                    imem_addr_r[31:6] <= imem_addr_r_new[31:6];
                end
            end
        end else if (new_pc_req) begin
            imem_addr_r <= new_pc[31:2];
        end
    end
end

assign num_txns_pending_new = num_txns_pending + (imem_req & imem_req_ack) - (imem_resp_ok | imem_resp_er);

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        num_txns_pending <= '0;
    end else if ((imem_req & imem_req_ack) ^ (imem_resp_ok | imem_resp_er)) begin
        num_txns_pending <= num_txns_pending_new;
    end
end


always @ (*) begin
    if (new_pc_req) begin
        discard_resp_cnt_new = num_txns_pending_new - (imem_req & imem_req_ack);
    end else if (imem_resp_er & ~discard_resp) begin
        discard_resp_cnt_new = num_txns_pending_new;
    end else begin
        discard_resp_cnt_new = discard_resp_cnt - 1'b1;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        discard_resp_cnt <= 3'h0;
    end else if (new_pc_req | imem_resp_er | (imem_resp_ok & discard_resp)) begin
        discard_resp_cnt <= discard_resp_cnt_new;
    end
end

assign num_vd_txns_pending  = num_txns_pending - discard_resp_cnt;
assign discard_resp         = |discard_resp_cnt;


//-------------------------------------------------------------------------------
// Control logic
//-------------------------------------------------------------------------------
reg nxt_fsm;

always @ (*) begin
  nxt_fsm = fsm;
  case (fsm)
      PEAK_FSM_IDLE:
      begin
          if (new_pc_req & ~stop_fetch) begin
              nxt_fsm = PEAK_FSM_FETCH;
          end
      end
      PEAK_FSM_FETCH: 
      begin
          if (stop_fetch | (imem_resp_er & ~discard_resp & ~new_pc_req)) begin
              nxt_fsm <= PEAK_FSM_IDLE;
          end
      end
  endcase 
end

always @ (posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0) begin
        fsm <= PEAK_FSM_IDLE;
    end
    else begin
	fsm <= nxt_fsm;
    end
end


always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        new_pc_unaligned    <= 1'b0;
    end else begin
        if (new_pc_req) begin
            new_pc_unaligned    <= new_pc[1];
        end else if (imem_resp_vd) begin
            new_pc_unaligned    <= 1'b0;
        end
    end
end

//-------------------------------------------------------------------------------
// Instruction decode unit interface
//-------------------------------------------------------------------------------

reg       ifu2dpu_imem_err;
reg       ifu2dpu_err_rvi_hi;
reg[1:0]  ifu2dpu_vd;

always @ (*) begin
    ifu2dpu_vd          = 1'b0;
    ifu2dpu_imem_err    = 1'b0;
    ifu2dpu_err_rvi_hi  = 1'b0;
    if (~q_empty) begin
        if (q_ocpd_h == 2'h1) begin
            ifu2dpu_vd[1:0]     = {1'b0, q_head_rvc | q_err_head};
            ifu2dpu_imem_err    = q_err_head;
        end else begin          
            ifu2dpu_vd          = {q_head_rvc & q_snd_rvc, 1'b1};
            ifu2dpu_imem_err    = q_err_head ? 1'b1 : (q_head_rvi & q_err_next);
            ifu2dpu_err_rvi_hi  = ~q_err_head & q_head_rvi & q_err_next;
        end
    end 
end

assign  ifu2dpu_instr = q_head_rvc & ~q_snd_rvc  ? {16'h0, q_data_head}: 
                                                   {q_data_next, q_data_head};


endmodule

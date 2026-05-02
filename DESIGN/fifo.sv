`timescale 1ns/1ps

// ==========================================================
// SIMPLE SYNCHRONOUS FIFO
// ==========================================================
module fifo #(
    parameter DATA_WIDTH = 8,
    parameter DEPTH = 8
)(
    input  wire clk,
    input  wire rst,
    input  wire wr_en,
    input  wire rd_en,
    input  wire [DATA_WIDTH-1:0] din,
    output reg  [DATA_WIDTH-1:0] dout,
    output wire full,
    output wire empty
);

    reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];
    reg [2:0] wr_ptr, rd_ptr;   // DEPTH=8 → 3 bits
    reg [3:0] count;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            wr_ptr <= 0;
            rd_ptr <= 0;
            count  <= 0;
            dout   <= 0;
        end else begin
            // WRITE
            if (wr_en && !full) begin
                mem[wr_ptr] <= din;
                wr_ptr <= wr_ptr + 1;
                count  <= count + 1;
            end

            // READ
            if (rd_en && !empty) begin
                dout <= mem[rd_ptr];
                rd_ptr <= rd_ptr + 1;
                count  <= count - 1;
            end
        end
    end

    assign full  = (count == DEPTH);
    assign empty = (count == 0);

endmodule


// ==========================================================
// 3-PORT ROUTER WITH ROUND ROBIN + REGISTERED OUTPUT
// ==========================================================
module router_rr #(
    parameter DATA_WIDTH = 8
)(
    input  wire clk,
    input  wire rst,

    input  wire [DATA_WIDTH-1:0] data_in,
    input  wire valid_in,
    output wire ready_out,

    output reg  [DATA_WIDTH-1:0] data_out,
    output reg  valid_out,
    input  wire ready_in
);

    // Destination (top 2 bits)
    wire [1:0] dest;
    assign dest = data_in[7:6];

    // FIFO signals
    reg wr_en0, wr_en1, wr_en2;
    reg rd_en0, rd_en1, rd_en2;

    wire full0, full1, full2;
    wire empty0, empty1, empty2;

    wire [DATA_WIDTH-1:0] fifo_out0, fifo_out1, fifo_out2;

    // Round robin pointer
    reg [1:0] last_grant, next_grant;

    // Internal mux signals
    reg [DATA_WIDTH-1:0] data_out_next;
    reg valid_out_next;

    // ================= FIFO INSTANCES =================
    fifo #(DATA_WIDTH,8) f0 (
        .clk(clk), .rst(rst),
        .wr_en(wr_en0), .rd_en(rd_en0),
        .din(data_in), .dout(fifo_out0),
        .full(full0), .empty(empty0)
    );

    fifo #(DATA_WIDTH,8) f1 (
        .clk(clk), .rst(rst),
        .wr_en(wr_en1), .rd_en(rd_en1),
        .din(data_in), .dout(fifo_out1),
        .full(full1), .empty(empty1)
    );

    fifo #(DATA_WIDTH,8) f2 (
        .clk(clk), .rst(rst),
        .wr_en(wr_en2), .rd_en(rd_en2),
        .din(data_in), .dout(fifo_out2),
        .full(full2), .empty(empty2)
    );

    // ================= WRITE LOGIC =================
    always @(*) begin
        wr_en0 = 0; wr_en1 = 0; wr_en2 = 0;

        if (valid_in) begin
            if (dest == 0 && !full0) wr_en0 = 1;
            else if (dest == 1 && !full1) wr_en1 = 1;
            else if (dest == 2 && !full2) wr_en2 = 1;
        end
    end

    assign ready_out =
        (dest == 0 && !full0) ||
        (dest == 1 && !full1) ||
        (dest == 2 && !full2);

    // ================= ROUND ROBIN =================
    always @(*) begin
        // default
        data_out_next = 0;
        valid_out_next = 0;
        next_grant = last_grant;

        rd_en0 = 0; rd_en1 = 0; rd_en2 = 0;

        if (ready_in) begin
            case (last_grant)

                0: begin
                    if (!empty1) begin
                        data_out_next = fifo_out1;
                        rd_en1 = 1;
                        valid_out_next = 1;
                        next_grant = 1;
                    end else if (!empty2) begin
                        data_out_next = fifo_out2;
                        rd_en2 = 1;
                        valid_out_next = 1;
                        next_grant = 2;
                    end else if (!empty0) begin
                        data_out_next = fifo_out0;
                        rd_en0 = 1;
                        valid_out_next = 1;
                        next_grant = 0;
                    end
                end

                1: begin
                    if (!empty2) begin
                        data_out_next = fifo_out2;
                        rd_en2 = 1;
                        valid_out_next = 1;
                        next_grant = 2;
                    end else if (!empty0) begin
                        data_out_next = fifo_out0;
                        rd_en0 = 1;
                        valid_out_next = 1;
                        next_grant = 0;
                    end else if (!empty1) begin
                        data_out_next = fifo_out1;
                        rd_en1 = 1;
                        valid_out_next = 1;
                        next_grant = 1;
                    end
                end

                2: begin
                    if (!empty0) begin
                        data_out_next = fifo_out0;
                        rd_en0 = 1;
                        valid_out_next = 1;
                        next_grant = 0;
                    end else if (!empty1) begin
                        data_out_next = fifo_out1;
                        rd_en1 = 1;
                        valid_out_next = 1;
                        next_grant = 1;
                    end else if (!empty2) begin
                        data_out_next = fifo_out2;
                        rd_en2 = 1;
                        valid_out_next = 1;
                        next_grant = 2;
                    end
                end

                default: next_grant = 0;

            endcase
        end
    end

    // ================= OUTPUT REGISTER =================
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            data_out  <= 0;
            valid_out <= 0;
            last_grant <= 0;
        end else begin
            data_out  <= data_out_next;
            valid_out <= valid_out_next;

            if (valid_out_next)
                last_grant <= next_grant;
        end
    end

endmodule

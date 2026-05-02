`timescale 1ns/1ps

module tb;

    parameter DATA_WIDTH = 8;

    reg clk, rst;
    reg [DATA_WIDTH-1:0] data_in;
    reg valid_in;
    wire ready_out;

    wire [DATA_WIDTH-1:0] data_out;
    wire valid_out;
    reg ready_in;

    // ================= DUT =================
    router_rr dut (
        .clk(clk),
        .rst(rst),
        .data_in(data_in),
        .valid_in(valid_in),
        .ready_out(ready_out),
        .data_out(data_out),
        .valid_out(valid_out),
        .ready_in(ready_in)
    );

    // ================= CLOCK =================
    initial clk = 0;
    always #5 clk = ~clk;

    // ================= SCOREBOARD =================
    reg [7:0] q0[0:199], q1[0:199], q2[0:199];
    integer t0[0:199], t1[0:199], t2[0:199];

    integer w0, w1, w2;
    integer r0, r1, r2;

    // MUST be declared here (Verilog rule)
    integer latency;
    reg [1:0] dest;

    // ================= MONITOR =================
    always @(posedge clk) begin
        if (valid_out && ready_in) begin
            dest = data_out[7:6];

            case (dest)
                0: begin
                    if (data_out !== q0[r0])
                        $display("ERROR FIFO0 exp=%h got=%h @%0t", q0[r0], data_out, $time);
                    latency = $time - t0[r0];
                    r0 = r0 + 1;
                end

                1: begin
                    if (data_out !== q1[r1])
                        $display("ERROR FIFO1 exp=%h got=%h @%0t", q1[r1], data_out, $time);
                    latency = $time - t1[r1];
                    r1 = r1 + 1;
                end

                2: begin
                    if (data_out !== q2[r2])
                        $display("ERROR FIFO2 exp=%h got=%h @%0t", q2[r2], data_out, $time);
                    latency = $time - t2[r2];
                    r2 = r2 + 1;
                end

                default: begin
                    $display("ERROR: invalid destination %0d @%0t", dest, $time);
                end
            endcase

            $display("PASS: data=%h latency=%0d @%0t", data_out, latency, $time);
        end
    end

    // ================= DRIVER =================
    task send_packet;
        input [1:0] dest_in;
        input [5:0] payload;

        reg [7:0] pkt;

        begin
            pkt = {dest_in, payload};

            @(posedge clk);

            if (ready_out) begin
                data_in  = pkt;
                valid_in = 1;

                case (dest_in)
                    0: begin q0[w0]=pkt; t0[w0]=$time; w0=w0+1; end
                    1: begin q1[w1]=pkt; t1[w1]=$time; w1=w1+1; end
                    2: begin q2[w2]=pkt; t2[w2]=$time; w2=w2+1; end
                    default: ;
                endcase

                $display("SEND: %h dest=%0d @%0t", pkt, dest_in, $time);
            end

            @(posedge clk);
            valid_in = 0;
        end
    endtask

    // ================= TEST SEQUENCE =================
    initial begin
        rst = 1;
        valid_in = 0;
        data_in = 0;
        ready_in = 1;

        w0=0; w1=0; w2=0;
        r0=0; r1=0; r2=0;

        #20 rst = 0;

        // -------- BASIC --------
        send_packet(0,10);
        send_packet(1,20);
        send_packet(2,30);

        // -------- RANDOM --------
        repeat (20)
            send_packet($random % 3, $random % 64);

        // -------- BURST --------
        repeat (10)
            send_packet(1, $random % 64);

        // -------- SAME DEST --------
        repeat (10)
            send_packet(0, $random % 64);

        // -------- ROUND ROBIN --------
        send_packet(0,1);
        send_packet(1,2);
        send_packet(2,3);
        send_packet(0,4);
        send_packet(1,5);
        send_packet(2,6);

        // -------- BACKPRESSURE --------
        ready_in = 0;
        repeat (5)
            send_packet(2, $random % 64);
        #50 ready_in = 1;

        // -------- STRESS --------
        repeat (50) begin
            ready_in = $random % 2;
            send_packet($random % 3, $random % 64);
        end

        ready_in = 1;

        #200;
        $display("SIMULATION COMPLETE");
        $finish;
    end

endmodule

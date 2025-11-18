// -----------------------------------------------------------------------------
// sec_lowest_tb.sv
//
// 11/17/2025 S. Janamian (saba.janamian@csun.edu)
//
// Testbench for module capture the second lowest value in a stream of 16 bit 
// values.
//
// -----------------------------------------------------------------------------

module sec_lowest_tb;

timeunit 1ns;
timeprecision 100ps;

//------------------------------------------------------------------------------
// Testbench local parameters
//------------------------------------------------------------------------------

localparam time        CP             = 10ns;
localparam integer     TEST_ITERATION = 100;

//------------------------------------------------------------------------------
// Testbench internal signals
//------------------------------------------------------------------------------
logic        clk;
logic        rst_n;
logic        valid;
logic [15:0] data;
logic [15:0] second_lowest;

logic [15:0] stream_test_array[$];

int          array_size;
int          fail_count;
int          total_iterations;

//------------------------------------------------------------------------------
// DUT instance
//------------------------------------------------------------------------------
sec_lowest uut(
    .clk           (clk          ),
    .rst_n         (rst_n        ),
    .valid         (valid        ),
    .data          (data         ),
    .second_lowest (second_lowest)
);

//------------------------------------------------------------------------------
// GEnerating clock
//------------------------------------------------------------------------------
initial begin
    clk   = 'b0;
    forever begin
        #(CP/2) clk = ~clk;
    end
end


//------------------------------------------------------------------------------
// Stimulus
//------------------------------------------------------------------------------
initial begin
    valid            = 'b0;
    data             = 'b0;
    fail_count       = 0;
    total_iterations = 0;
    array_size       = 0;

    repeat(TEST_ITERATION) begin
        rst_n = 'b0;
        repeat(4) @(posedge clk);
        rst_n = 'b1;

        stream_test_array.delete(); // Makeing sure array is empty on each iter

        repeat(10) begin
            valid = 'b1;
            data  = $urandom_range(16'hFFFF, 0);

            stream_test_array.push_back(data);
            stream_test_array = stream_test_array.unique();

            @(posedge clk);

            stream_test_array.sort();
            array_size = stream_test_array.size();

            total_iterations++;

            if (array_size < 2) begin
                continue;
            end

            @(negedge clk);
            assert(stream_test_array[1] == second_lowest) else begin
                $display("FAILED: Expected %0d, Actual %0d, %p",
                stream_test_array[1], second_lowest, stream_test_array);
                fail_count++;
            end
        end

        valid = 'b0;
        data  = 'b0;
        @(posedge clk);
    end

    $display("----------------------------------------");
    $display("Test Result");
    $display("Total iterations: %0d", total_iterations);
    $display("Fail count      :     %0d", fail_count);
    $display("----------------------------------------");

    $stop;
end


//------------------------------------------------------------------------------
// Monitor
//------------------------------------------------------------------------------
initial begin
    $timeformat(-9, 0, "ns", 16);
    $monitor("%0t: rst_n: %b valid: %b, data %0d, second_lowest: %0d", $time,
        rst_n, valid, data, second_lowest);
end

endmodule
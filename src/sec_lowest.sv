// -----------------------------------------------------------------------------
// sec_lowest.sv
//
// 11/17/2025 S. Janamian (saba.janamian@csun.edu)
//
// Simple module to capture the second lowest value in a stream of 16 bit values
//
// -----------------------------------------------------------------------------

module sec_lowest(
    input  logic        clk,
    input  logic        rst_n,
    input  logic        valid,
    input  logic [15:0] data,
    output logic [15:0] second_lowest
);

// -----------------------------------------------------------------------------
// Internal Signals
// -----------------------------------------------------------------------------
logic [15:0] first_lowest;

// -----------------------------------------------------------------------------
// Second lowest detector
// -----------------------------------------------------------------------------
always_ff @(posedge clk) begin

    if (!rst_n) begin

        first_lowest  <= '1;
        second_lowest <= '1;

    end else begin

        if (valid) begin
            if (data < first_lowest) begin

                first_lowest  <= data;
                second_lowest <= first_lowest;

            end else if (data > first_lowest && data < second_lowest) begin

                first_lowest  <= first_lowest;
                second_lowest <= data;

            end
        end
    end
end

endmodule

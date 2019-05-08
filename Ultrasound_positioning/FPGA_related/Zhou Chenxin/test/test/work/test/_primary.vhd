library verilog;
use verilog.vl_types.all;
entity test is
    port(
        clk             : in     vl_logic;
        y_out           : out    vl_logic_vector(15 downto 0);
        phase_in        : in     vl_logic_vector(15 downto 0)
    );
end test;

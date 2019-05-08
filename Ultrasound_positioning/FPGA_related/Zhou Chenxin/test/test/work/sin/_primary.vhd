library verilog;
use verilog.vl_types.all;
entity sin is
    port(
        clk             : in     vl_logic;
        x_out           : out    vl_logic_vector(15 downto 0);
        phase_in        : in     vl_logic_vector(15 downto 0)
    );
end sin;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity divider is
    	generic(
        	N : integer := 100000000
    	);
	port(
	   	CLK, RESET : in std_logic;
       		RESULT_CLK : out std_logic
	);
end divider;

architecture behavioral of divider is	

	signal ticks  : std_logic_vector(31 downto 0) := (others => '0');
	signal result : std_logic := '0';
	
begin
    process(CLK, RESET) begin
        if(RESET = '1') then
            ticks <= (others => '0');
        elsif rising_edge(CLK) then 
            ticks <= ticks + 1;
            if(ticks < N) then
                result <= '0';
            else
                result <= '1';
                ticks <= (others => '0');
            end if;
        end if;
    end process;
    RESULT_CLK <= result;
end behavioral;

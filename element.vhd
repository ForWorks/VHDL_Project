library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

entity element is
    port(
        CLK, RESET    : in std_logic;
        POSITION      : out std_logic_vector(7 downto 0);
        DISPLAY_DIGIT : out std_logic_vector(6 downto 0);
        LEDS          : out std_logic_vector(15 downto 0)
    );
end element;

architecture Behavioral of element is
    
    constant rom_size    : integer := 52;
    constant comand_size : integer := 16;    
    signal rom_position  : integer := 0;
    
    signal digit_vector     : std_logic_vector(15 downto 0);
    signal counter          : std_logic_vector(17 downto 0);
    signal digit            : std_logic_vector(3 downto 0);
    signal clk_x1           : std_logic;
    signal clk_x2           : std_logic;
    
    type rom_type is array(0 to rom_size - 1) of std_logic_vector(comand_size - 1 downto 0);
    constant ROM: rom_type := (
         x"8000", x"4000", x"2000", x"1000", x"0800", x"0400", x"0200", x"0100",
         x"0080", x"0040", x"0020", x"0010", x"0008", x"0004", x"0002", x"0001",
         x"0003", x"000c", x"0030", x"00c0", x"0300", x"0c00", x"3000", x"c000",
         x"f000", x"3c00", x"0f00", x"03c0", x"00f0", x"003c", x"000f", x"003f",
         x"00fc", x"03f0", x"0fc0", x"3f00", x"fc00", x"ff00", x"3fc0", x"0ff0",
         x"03fc", x"00ff", x"03ff", x"0ffc", x"3ff0", x"ffc0", x"fff0", x"3ffc",
         x"0fff", x"3fff", x"fffc", x"ffff"
    );
        
begin

    div : entity work.divider generic map(100000000) port map(CLK => CLK, RESET => RESET, RESULT_CLK => clk_x1);
    div2 : entity work.divider generic map(50000000) port map(CLK => CLK, RESET => RESET, RESULT_CLK => clk_x2);
    
    process(digit) begin
        case digit is
            when "0000" => DISPLAY_DIGIT <= "1000000"; 
            when "0001" => DISPLAY_DIGIT <= "1111001"; 
            when "0010" => DISPLAY_DIGIT <= "0100100"; 
            when "0011" => DISPLAY_DIGIT <= "0110000"; 
            when "0100" => DISPLAY_DIGIT <= "0011001"; 
            when "0101" => DISPLAY_DIGIT <= "0010010"; 
            when "0110" => DISPLAY_DIGIT <= "0000010"; 
            when "0111" => DISPLAY_DIGIT <= "1111000"; 
            when "1000" => DISPLAY_DIGIT <= "0000000"; 
            when "1001" => DISPLAY_DIGIT <= "0010000"; 
            when others => DISPLAY_DIGIT <= "1111111"; 
        end case;
    end process;
    
    process(CLK, RESET) begin
        if(RESET = '1') then 
            counter <= (others => '0');
        elsif(rising_edge(CLK)) then
            counter <= counter + 1;
        end if;
    end process;
    
    process(counter(17 downto 16)) begin       
        case counter(17 downto 16) is
            when "00" =>
                POSITION <= "11101111";
                digit <= digit_vector(15 downto 12);
            when "01" =>
                POSITION <= "11011111";
                digit <= digit_vector(11 downto 8);
            when "10" =>
                POSITION <= "10111111";
                digit <= digit_vector(7 downto 4);
            when "11" =>
                POSITION <= "01111111";
                digit <= digit_vector(3 downto 0);
            when others =>
                POSITION <= "11111111";
        end case;
    end process;
    
    process(clk_x1, RESET) begin 
        if(RESET = '1') then
            digit_vector <= (others => '0');
        elsif(rising_edge(clk_x1)) then              
            if(digit_vector(3 downto 0) < "1001") then
                digit_vector(3 downto 0) <= digit_vector(3 downto 0) + 1;
            else
                digit_vector(3 downto 0) <= (others => '0');
                if(digit_vector(7 downto 4) < "1001") then
                    digit_vector(7 downto 4) <= digit_vector(7 downto 4) + 1;
                else
                    digit_vector(7 downto 4) <= (others => '0');
                    if(digit_vector(11 downto 8) < "1001") then
                        digit_vector(11 downto 8) <= digit_vector(11 downto 8) + 1;
                    else
                        digit_vector(11 downto 8) <= (others => '0');
                        if(digit_vector(15 downto 12) < "1001") then
                            digit_vector(15 downto 12) <= digit_vector(15 downto 12) + 1;
                        else
                            digit_vector(15 downto 12) <= (others => '0'); 
                        end if;
                    end if;
                end if;
            end if;
        end if;
     end process;
     
     process(clk_x2, RESET) begin 
        if(RESET = '1') then
            rom_position <= 0;
            LEDS <= x"0000";
        elsif(rising_edge(clk_x2)) then            
            if(rom_position < rom_size - 1) then                       
                rom_position <= rom_position + 1;
            else
                rom_position <= 0;
            end if;      
            LEDS <= ROM(rom_position); 
        end if;
     end process;
          
end Behavioral;

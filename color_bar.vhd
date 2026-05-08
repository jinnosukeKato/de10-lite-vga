library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity color_bar is
	port (
		clk : in std_logic;
		red : out std_logic_vector(3 downto 0);
		green : out std_logic_vector(3 downto 0);
		blue : out std_logic_vector(3 downto 0);
		v_sync : out std_logic;
		h_sync : out std_logic
	);
end color_bar;

architecture RTL of color_bar is
	signal clk_25MHz : std_logic := '0';
	signal rgb : std_logic_vector(2 downto 0) := (others => '0');

	signal h_sync_counter : unsigned(9 downto 0) := (others => '0');
  signal h_sync_internal : std_logic := '0';
	signal h_display : std_logic := '0';

	signal v_sync_counter : unsigned(9 downto 0) := (others => '0');
  signal v_sync_internal : std_logic := '0';
	signal v_display : std_logic := '0';
begin
	-- Generate a 25 MHz clock from the 50 MHz input clock
	generate_clk: process(clk)
	begin
		if rising_edge(clk) then
			clk_25MHz <= not clk_25MHz;
		end if;
	end process generate_clk;

	-- Output RGB values
	red <= "1111" when (h_display = '1' and v_display = '1' and rgb(0) = '1') else "0000";
	green <= "1111" when (h_display = '1' and v_display = '1' and rgb(1) = '1') else "0000";
	blue <= "1111" when (h_display = '1' and v_display = '1' and rgb(2) = '1') else "0000";

	-- Output sync signals
	h_sync <= h_sync_internal;
	v_sync <= v_sync_internal;

	-- Counting horizontal sync timing
	h_sync_count: process(clk_25MHz)
	begin
		if h_sync_counter = 799 then
			h_sync_counter <= (others => '0');
		elsif rising_edge(clk_25MHz) then
			h_sync_counter <= h_sync_counter + 1;
		end if;
	end process h_sync_count;

	-- Generate horizontal sync signal
	gen_h_sync: process(clk_25MHz)
	begin
		-- Horizontal sync pulse is active high for the first 96 counts
		if (h_sync_counter < 96) then
			h_sync_internal <= '0';
		else
			h_sync_internal <= '1';
		end if;
	end process gen_h_sync;

	h_display_output: process(clk_25MHz)
	begin
		if (h_sync_counter >= 144 and h_sync_counter < 784) then
			h_display <= '1'; -- Display area
		else
			h_display <= '0'; -- Non-display area
		end if;
	end process h_display_output;


	-- Counting the horizontal lines for vertical sync timing
	v_sync_count: process(h_sync_internal)
	begin
		if rising_edge(h_sync_internal) then
			if v_sync_counter = 520 then
				v_sync_counter <= (others => '0');
			else
				v_sync_counter <= v_sync_counter + 1;
			end if;
		end if;
	end process v_sync_count;

	-- Generate vertical sync signal
	gen_v_sync: process(v_sync_internal)
	begin
		if (v_sync_counter < 2) then
			v_sync_internal <= '0';
		else
			v_sync_internal <= '1';
		end if;
	end process gen_v_sync;

	v_display_output: process(h_sync_internal)
	begin
		if (v_sync_counter >= 31 and v_sync_counter < 511) then
			v_display <= '1'; -- Display area
		else
			v_display <= '0'; -- Non-display area
		end if;
	end process v_display_output;

	-- Simple color bar pattern generator
	color_bar: process(h_sync_counter)
	begin
		case to_integer(h_sync_counter) is
			when 0   to 223 => rgb <= "000"; -- Black
			when 224 to 303 => rgb <= "001"; -- Red
			when 304 to 383 => rgb <= "010"; -- Green
			when 384 to 463 => rgb <= "011"; -- Blue
			when 464 to 543 => rgb <= "100"; -- Yellow
			when 544 to 623 => rgb <= "101"; -- Magenta
			when 624 to 703 => rgb <= "110"; -- Cyan
			when others => rgb <= "111"; -- White
		end case;
	end process color_bar;
end architecture RTL;

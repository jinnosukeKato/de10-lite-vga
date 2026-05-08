library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity de10_lite_vga is
	port (
		MAX10_CLK1_50 : in std_logic;
		VGA_R         : out std_logic_vector(3 downto 0);
		VGA_G         : out std_logic_vector(3 downto 0);
		VGA_B         : out std_logic_vector(3 downto 0);
		VGA_HS        : out std_logic;
		VGA_VS        : out std_logic
	);
end de10_lite_vga;

architecture RTL of de10_lite_vga is
	component color_bar
		port (
			clk    : in  std_logic;
			red    : out std_logic_vector(3 downto 0);
			green  : out std_logic_vector(3 downto 0);
			blue   : out std_logic_vector(3 downto 0);
			v_sync : out std_logic;
			h_sync : out std_logic
		);
	end component;

begin
	u_color_bar : color_bar
		port map (
			clk    => MAX10_CLK1_50,
			red    => VGA_R,
			green  => VGA_G,
			blue   => VGA_B,
			v_sync => VGA_VS,
			h_sync => VGA_HS
		);
end RTL;

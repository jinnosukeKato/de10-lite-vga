--! @author Jinnosuke KATO
--! @brief DE10-LiteのVGA端子へ640x480 60Hzのモードでカラーバーを出力するモジュール

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

--! DE10-LiteのVGA端子へ640x480 60Hzのモードでカラーバーを出力するモジュール
entity de10_lite_vga is
  port (
    MAX10_CLK1_50 : in std_logic; --! DE10-Liteの50MHzクロック入力
    VGA_R         : out std_logic_vector(3 downto 0); --! 赤色信号出力
    VGA_G         : out std_logic_vector(3 downto 0); --! 緑色信号出力
    VGA_B         : out std_logic_vector(3 downto 0); --! 青色信号出力
    VGA_HS        : out std_logic; --! 水平同期信号出力
    VGA_VS        : out std_logic --! 垂直同期信号出力
  );
end de10_lite_vga;

architecture RTL of de10_lite_vga is
  component vga_driver is
    port (
      clk            : in std_logic;
      rgb            : in std_logic_vector(2 downto 0);
      vertical_pos   : out unsigned(9 downto 0);
      horizontal_pos : out unsigned(9 downto 0);
      red            : out std_logic_vector(3 downto 0);
      green          : out std_logic_vector(3 downto 0);
      blue           : out std_logic_vector(3 downto 0);
      v_sync         : out std_logic;
      h_sync         : out std_logic
    );
  end component;

  component character_controller is
    port (
      clk            : in std_logic;
      horizontal_pos : in unsigned(9 downto 0);
      vertical_pos   : in unsigned(9 downto 0);
      rgb            : out std_logic_vector(2 downto 0)
    );
  end component;

  signal horizontal_pos : unsigned(9 downto 0); --! 描画する水平座標
  signal vertical_pos   : unsigned(9 downto 0); --! 描画する垂直座標
  signal rgb            : std_logic_vector(2 downto 0); --! 座標に対応したRGB信号の内部表現 各々1ビットでR,G,Bの順
begin
  --! vga_driverモジュールのインスタンス
  u_vga_driver : vga_driver
  port map
  (
    clk            => MAX10_CLK1_50,
    rgb            => rgb,
    vertical_pos   => vertical_pos,
    horizontal_pos => horizontal_pos,
    red            => VGA_R,
    green          => VGA_G,
    blue           => VGA_B,
    v_sync         => VGA_VS,
    h_sync         => VGA_HS
  );

  --! 文字表示を制御するモジュールのインスタンス
  u_character_controller : character_controller
  port map
  (
    clk            => MAX10_CLK1_50,
    horizontal_pos => horizontal_pos,
    vertical_pos   => vertical_pos,
    rgb            => rgb
  );
end RTL;

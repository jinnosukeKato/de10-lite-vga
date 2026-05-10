--! @author Jinnosuke KATO
--! @brief DE10-LiteのVGA端子へ640x480 60Hzのモードでカラーバーを出力するモジュール

library IEEE;
use IEEE.STD_LOGIC_1164.all;

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
  component color_bar
    port (
      clk    : in std_logic;
      red    : out std_logic_vector(3 downto 0);
      green  : out std_logic_vector(3 downto 0);
      blue   : out std_logic_vector(3 downto 0);
      v_sync : out std_logic;
      h_sync : out std_logic
    );
  end component;

begin
  --! color_barモジュールをインスタンス化し，DE10-LiteのクロックとVGA信号ポートに接続する
  u_color_bar : color_bar
  port map
  (
    clk    => MAX10_CLK1_50,
    red    => VGA_R,
    green  => VGA_G,
    blue   => VGA_B,
    v_sync => VGA_VS,
    h_sync => VGA_HS
  );
end RTL;

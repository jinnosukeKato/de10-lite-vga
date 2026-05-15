--! @author Jinnosuke KATO
--! @brief 文字を出力するモジュール

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity character_controller is
  port (
    clk            : in std_logic; --! クロック信号
    horizontal_pos : in unsigned(9 downto 0); --! 描画する水平座標
    vertical_pos   : in unsigned(9 downto 0); --! 描画する垂直座標
    rgb            : out std_logic_vector(2 downto 0) --! 座標に対応したRGB信号の出力 各々1ビットでR,G,Bの順
  );
end character_controller;

architecture RTL of character_controller is
  signal pixel_on : std_logic; --! 文字のピクセルがオンかオフかを表す信号
  component character_generator is
    port (
      clk        : in std_logic;
      ascii_code : in std_logic_vector(7 downto 0);
      row        : in unsigned(2 downto 0);
      col        : in unsigned(2 downto 0);
      pixel_on   : out std_logic
    );
  end component;
begin
  --! character_generatorモジュールをインスタンス化し，水平座標と垂直座標から文字のピクセル情報を読み出してRGB信号に変換する
  u_character_generator : character_generator
  port map
  (
    clk        => clk,
    ascii_code => std_logic_vector(to_unsigned(65, 8)), --! 今回はAを表示する
    row        => vertical_pos(2 downto 0), --! 垂直座標の下位3ビットを行番号として使用する
    col        => horizontal_pos(2 downto 0), --! 水平座標の下位3ビットを列番号として使用する
    pixel_on   => pixel_on --! ピクセルがオンであれば赤色信号をオンにする
  );

  rgb <= "111" when pixel_on = '1' else
    "000";
end architecture RTL;

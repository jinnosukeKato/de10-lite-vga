--! @author: Jinnosuke KATO
--! @brief: 8x8ドットのビットマップフォントを格納するROMから文字のピクセル情報を読み出すモジュール

use STD.textio.all;

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
use IEEE.std_logic_textio.all;

--! 8x8ドットのビットマップフォントを格納するROMから文字のピクセル情報を読み出すモジュール
entity character_generator is
  port (
    clk        : in std_logic; --! クロック信号
    ascii_code : in std_logic_vector(7 downto 0); --! 表示する文字のASCIIコード
    row        : in unsigned(2 downto 0); --! 描画するピクセルの行番号(0-7)
    col        : in unsigned(2 downto 0); --! 描画するピクセルの列番号(0-7)
    pixel_on   : out std_logic --! 文字の(row, col)の位置に対応するピクセルがオンであるかを示す信号
  );
end character_generator;

architecture RTL of character_generator is
  type font_rom_type is array (0 to 128 * 8 - 1) of std_logic_vector(7 downto 0); --! 8x8ドットのビットマップを128文字分格納するROM

  signal font_rom                          : font_rom_type; --! フォントROM
  attribute font_rom_init_attr             : string; --! フォントROM初期化ファイルの属性
  attribute font_rom_init_attr of font_rom : signal is "font/font.mif"; -- Quartus用のメモリ初期化ファイル(.mif)を属性として指定し，フォントROMを初期化

  signal font_row_addr : integer range 0 to 1023;
  signal font_row      : std_logic_vector(7 downto 0);
  signal font_col      : unsigned(2 downto 0);
begin
  -- フォントの描画する行のアドレスを計算
  font_row_addr <= to_integer(unsigned(ascii_code)) * 8 + to_integer(row);

  -- ROMから取り出したフォントの行データから描画する列のビットを取り出してpixel_on信号に出力する
  pixel_on <= '1' when font_row(7 - to_integer(font_col)) = '1' else
    '0';

  process (clk)
  begin
    if rising_edge(clk) then
      font_row <= font_rom(font_row_addr);
      font_col <= col;
    end if;
  end process;
end architecture RTL;

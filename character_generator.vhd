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

  signal font_rom         : font_rom_type;
  attribute ram_init_file : string;
  -- Quartus用のメモリ初期化ファイル(.mif)を属性として指定する
  attribute ram_init_file of font_rom : signal is "font/font.mif";

  signal char_addr : integer range 0 to 1023;
  signal ram_q     : std_logic_vector(7 downto 0);
  signal col_reg   : unsigned(2 downto 0);
begin
  char_addr <= to_integer(unsigned(ascii_code)) * 8 + to_integer(row); --! 文字の描画するピクセルのアドレスを計算
  pixel_on  <= '1' when ram_q(7 - to_integer(col_reg)) = '1' else
    '0';

  process (clk)
  begin
    if rising_edge(clk) then
      ram_q   <= font_rom(char_addr);
      col_reg <= col;
    end if;
  end process;
end architecture RTL;

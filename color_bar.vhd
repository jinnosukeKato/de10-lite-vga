--! @author Jinnosuke KATO
--! @brief 640の横幅に対してカラーバーを出力するモジュール

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity color_bar is
  port (
    horizontal_pos : in unsigned(9 downto 0); --! 描画する水平座標
    vertical_pos   : in unsigned(9 downto 0); --! 描画する垂直座標
    rgb            : out std_logic_vector(2 downto 0) --! 座標に対応したRGB信号の出力 各々1ビットでR,G,Bの順
  );
end color_bar;

architecture RTL of color_bar is
begin
  color_bar : process (horizontal_pos)
  begin
    -- 横幅640を8等分して80ずつにする
    case to_integer(horizontal_pos) is
      when 0 to 79    => rgb    <= "000"; -- Black
      when 80 to 159  => rgb  <= "001"; -- Red
      when 160 to 239 => rgb <= "010"; -- Green
      when 240 to 319 => rgb <= "011"; -- Blue
      when 320 to 399 => rgb <= "100"; -- Yellow
      when 400 to 479 => rgb <= "101"; -- Magenta
      when 480 to 559 => rgb <= "110"; -- Cyan
      when others     => rgb     <= "111"; -- White
    end case;
  end process color_bar;
end RTL;
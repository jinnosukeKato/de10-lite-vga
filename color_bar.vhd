--! @author Jinnosuke KATO
--! @brief 640x480 60HzのVGAモードでカラーバーを出力するモジュール

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

--! カラーバーの生成とVGA信号の出力を行うモジュール

--! 参考文献
--! - 芹井 滋喜，50K MAX10搭載!FPGAスタータキット DE10-Lite入門，CQ出版，2020
--! - https://glenwing.github.io/docs/VESA-DMT-1.13.pdf
entity color_bar is
  port (
    clk    : in std_logic; --! DE10-Liteの50MHzクロック
    red    : out std_logic_vector(3 downto 0); --! 赤色信号出力
    green  : out std_logic_vector(3 downto 0); --! 緑色信号出力
    blue   : out std_logic_vector(3 downto 0); --! 青色信号出力
    v_sync : out std_logic; --! 垂直同期信号出力
    h_sync : out std_logic --! 水平同期信号出力
  );
end color_bar;

--! カラーバーの生成とVGA信号の出力を行うモジュールのアーキテクチャ
--! 水平同期信号と垂直同期信号を生成し、表示エリア内でrgb信号に基づいて色を出力する
architecture RTL of color_bar is
  signal clk_25MHz : std_logic                    := '0'; --! VGA同期用25 MHzクロック
  signal rgb       : std_logic_vector(2 downto 0) := (others => '0'); --! RGB信号の内部表現

  signal h_sync_counter  : unsigned(9 downto 0) := (others => '0'); --! 水平方向カウンタ(0-799)
  signal h_sync_internal : std_logic            := '0'; --! 水平同期信号の内部表現
  signal h_display       : std_logic            := '0'; --! 水平方向における表示エリア内であるかを示す信号

  signal v_sync_counter  : unsigned(9 downto 0) := (others => '0'); --! 垂直方向カウンタ(0-520)
  signal v_sync_internal : std_logic            := '0'; --! 垂直同期信号の内部表現
  signal v_display       : std_logic            := '0'; --! 垂直方向における表示エリア内であるかを示す信号
begin

  --! DE10-Liteの50MHzクロックを分周して25MHzクロックを生成する
  generate_clk : process (clk)
  begin
    if rising_edge(clk) then
      clk_25MHz <= not clk_25MHz;
    end if;
  end process generate_clk;

  --! 垂直および水平の表示エリア内で、rgb信号に基づいて色を出力する
  red <= "1111" when (h_display = '1' and v_display = '1' and rgb(0) = '1') else
    "0000";
  green <= "1111" when (h_display = '1' and v_display = '1' and rgb(1) = '1') else
    "0000";
  blue <= "1111" when (h_display = '1' and v_display = '1' and rgb(2) = '1') else
    "0000";

  --! 出力用の水平同期信号と垂直同期信号ポートに内部信号を接続する
  h_sync <= h_sync_internal;
  v_sync <= v_sync_internal;

  --! 水平方向へのクロックカウント
  h_sync_count : process (clk_25MHz)
  begin
    if rising_edge(clk_25MHz) then
      -- 800クロックで水平同期信号が1周期する
      -- このコードでは以下の順番でクロックをカウント，動作する
      -- 水平同期 96 + バックポーチ 40 + 左ボーダ 8 + 表示エリア 640 + 右ボーダ 8 + フロントポーチ 8 = 800
      if h_sync_counter = 799 then
        h_sync_counter <= (others => '0');
      else
        h_sync_counter <= h_sync_counter + 1;
      end if;
    end if;
  end process h_sync_count;

  --! 水平同期信号の生成
  gen_h_sync : process (clk_25MHz)
  begin
    if rising_edge(clk_25MHz) then
      -- 0-95クロック目に水平同期信号をアクティブにする
      if (h_sync_counter < 96) then
        h_sync_internal <= '0'; -- アクティブロー
      else
        h_sync_internal <= '1';
      end if;
    end if;
  end process gen_h_sync;

  --! 水平方向における表示エリアであるか判定する
  h_display_output : process (clk_25MHz)
  begin
    if rising_edge(clk_25MHz) then
      -- 水平同期 96 + バックポーチ 40 + 左ボーダ 8 = 144クロック目から表示エリアが開始
      -- 表示エリアは640クロック続くので，144 + 640 = 784クロック目まで表示エリア
      if (h_sync_counter >= 144 and h_sync_counter < 784) then
        h_display <= '1'; -- Display area
      else
        h_display <= '0'; -- Non-display area
      end if;
    end if;
  end process h_display_output;

  --! 水平方向のカウントが1周するごとに垂直方向のカウントを更新する
  v_sync_count : process (clk_25MHz)
  begin
    if rising_edge(clk_25MHz) then
      -- 水平同期信号の終わりで垂直カウンタを更新
      if h_sync_counter = 96 then
        -- 垂直同期 2 + バックポーチ 25 + 上ボータ 8 + 表示エリア 480 + 下ボーダ 8 + フロントポーチ 2 = 525
        -- 525クロックで垂直同期信号が1周期する
        -- ...はずだが，この実装では520クロックでリセットしてる，本をもう一度読んでその真意を確認する必要がありそう
        if v_sync_counter = 520 then
          v_sync_counter <= (others => '0');
        else
          v_sync_counter <= v_sync_counter + 1;
        end if;
      end if;
    end if;
  end process v_sync_count;

  --! 垂直同期信号の生成
  gen_v_sync : process (clk_25MHz)
  begin
    if rising_edge(clk_25MHz) then
      -- 0-1クロック目に垂直同期信号をアクティブローにする
      if (v_sync_counter < 2) then
        v_sync_internal <= '0';
      else
        v_sync_internal <= '1';
      end if;
    end if;
  end process gen_v_sync;

  --! 垂直方向における表示エリアであるか判定する
  v_display_output : process (clk_25MHz)
  begin
    if rising_edge(clk_25MHz) then
      -- 垂直同期 2 + バックポーチ 25 + 上ボータ 8 = 35クロック目から表示エリアが開始
      -- 表示エリアは480クロック続くので，35 + 480 = 515クロック目まで表示エリア
      -- ...のはずだが，この実装では510クロック目までを表示エリアとしている
      -- 恐らく520クロックでリセットする関係だと思われる
      if (v_sync_counter >= 31 and v_sync_counter < 511) then
        v_display <= '1'; -- 表示エリア
      else
        v_display <= '0'; -- 非表示エリア
      end if;
    end if;
  end process v_display_output;

  --!  水平カウンタの値に応じてrgb信号を更新してカラーバーを生成する
  color_bar : process (h_sync_counter)
  begin
    case to_integer(h_sync_counter) is
      when 0 to 223   => rgb   <= "000"; -- Black
      when 224 to 303 => rgb <= "001"; -- Red
      when 304 to 383 => rgb <= "010"; -- Green
      when 384 to 463 => rgb <= "011"; -- Blue
      when 464 to 543 => rgb <= "100"; -- Yellow
      when 544 to 623 => rgb <= "101"; -- Magenta
      when 624 to 703 => rgb <= "110"; -- Cyan
      when others     => rgb     <= "111"; -- White
    end case;
  end process color_bar;
end architecture RTL;

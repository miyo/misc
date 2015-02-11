library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity cam_sim is
end cam_sim;

architecture BEHAV of cam_sim is

  component cam
    generic (
      addr_width : integer := 8;
      tag_width : integer := 96
      );
    port (
      clk   : in std_logic;               -- clock
      reset : in std_logic;               -- reset, positive
      rd : in std_logic;                  -- Read
      wr : in std_logic;                  -- Write
      er : in std_logic;                  -- Erase
      data_in : in std_logic_vector(addr_width-1 downto 0);
      tag_in  : in std_logic_vector(tag_width-1 downto 0);
      data_out : out std_logic_vector(addr_width-1 downto 0);
      full     : out std_logic;
      hit      : out std_logic;
      ack      : out std_logic
      );
  end component cam;

  constant addr_width : integer := 8;
  constant tag_width  : integer := 96;
                         
  signal clk      : std_logic := '0';          -- clock
  signal reset    : std_logic := '1';          -- reset, positive
  signal rd       : std_logic := '0';          -- Read
  signal wr       : std_logic := '0';          -- Write
  signal er       : std_logic := '0';          -- Erase
  signal data_in  : std_logic_vector(addr_width-1 downto 0) := (others => '0');
  signal tag_in   : std_logic_vector(tag_width-1 downto 0) := (others => '0');
  signal data_out : std_logic_vector(addr_width-1 downto 0) := (others => '0');
  signal full     : std_logic := '0';
  signal hit      : std_logic := '0';
  signal ack      : std_logic := '0';

  signal counter : unsigned(31 downto 0) := (others => '0');

begin

  U : cam port map(
    clk      => clk,
    reset    => reset,
    rd       => rd,
    wr       => wr,
    er       => er,
    data_in  => data_in,
    tag_in   => tag_in,
    data_out => data_out,
    full     => full,
    hit      => hit,
    ack      => ack
    );

  process
  begin
    clk <= '1';
    wait for 10ns;
    clk <= '0';
    wait for 10ns;
  end process;

  process(clk)
  begin
    if clk'event and clk = '1' then
      counter <= counter + 1;

      case to_integer(counter) is
        when 50 => reset <= '0';
                   
        ---------------------------------------
        when 51 =>
          tag_in <= X"0123456789abcdef01234567";
          rd <= '1';
        when 52 => rd <= '0';
        ---------------------------------------
        ---------------------------------------
        when 53 =>
          wr <= '1';
          tag_in <= X"0123456789abcdef01234567";
          data_in <= X"FE";
        when 54 => wr <= '0';
        when 55 => wr <= '0';
        ---------------------------------------
        ---------------------------------------
        when 56 =>
          wr <= '1';
          tag_in <= X"AAAAAAAAAAAAAAAAAAAAAAAA";
          data_in <= X"34";
        when 57 => wr <= '0';
        when 58 => wr <= '0';
        ---------------------------------------
        ---------------------------------------
        when 59 =>
          rd <= '1';
          tag_in <= X"AAAAAAAAAAAAAAAAAAAAAAAA";
        when 60 => rd <= '0';
        ---------------------------------------
        when 61 =>
          rd <= '1';
          tag_in <= X"0123456789abcdef01234567";
        when 62 => rd <= '0';
        ---------------------------------------
        ---------------------------------------
        when 63 =>
          rd <= '1';
          tag_in <= X"AAAAAAAAAAAAAAAAAAAAAAAA";
        when 64 => rd <= '0';
        ---------------------------------------
        ---------------------------------------
        when 65 =>
          er <= '1';
          tag_in <= X"0123456789abcdef01234567";
        when 66 => er <= '0';
        when 67 => er <= '0';
        ---------------------------------------
        ---------------------------------------
        when 68 =>
          rd <= '1';
          tag_in <= X"0123456789abcdef01234567";
        when 69 => rd <= '0';
        ---------------------------------------
        ---------------------------------------
        when 70 =>
          wr <= '1';
          tag_in <= X"0123456789abcdef01234567";
          data_in <= X"AA";
        when 71 => wr <= '0';
        when 72 => wr <= '0';
        ---------------------------------------
        ---------------------------------------
        when 73 =>
          rd <= '1';
          tag_in <= X"0123456789abcdef01234567";
        when 74 => rd <= '0';
        ---------------------------------------
                   
        when others => null;
      end case;
    end if;
  end process;

end BEHAV;

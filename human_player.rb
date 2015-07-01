class HumanPlayer
  DIRECTIONS = {
    "w" => [-1,0],
    "a" => [0,-1],
    "s" => [1,0],
    "d" => [0,1]
  }
  def initialize(color)
    @color = color
  end

  def get_color
    @color
  end

  def get_source(display)
    user_input(display)
  end

  def get_destination(display)
    user_input(display)
  end

  def user_input(display)
    while true
      c = $stdin.getch
      if DIRECTIONS.has_key?(c)
        display.update_cursor(DIRECTIONS[c])
        display.render(get_color)
      elsif c == "\r"
        return display.get_cursor_position
      end
      exit if c == "\u0003"
    end
  end
end

class HumanPlayer
  DIRECTIONS = {
    "w" => [-1,0],
    "a" => [0,-1],
    "s" => [1,0],
    "d" => [0,1]
  }
  PROMOTIONS = {
    "q" => Queen,
    "k" => Knight,
    "b" => Bishop,
    "r" => Rook
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

  def get_promotion
    puts "Type {Q, R, B, K} to select the promotion."
    while true
      c = $stdin.getch
      if PROMOTIONS.has_key?(c)
        return PROMOTIONS[c]
      end
      exit if c == "\u0003"
    end
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

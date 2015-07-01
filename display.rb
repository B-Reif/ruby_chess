require_relative 'board'
require 'colorize'

class Display

  BG_COLORS = [
    :magenta,
    :blue
  ]

  def initialize(board)
    @board = board
    @cursor = [6,4] # king pawn
  end

  def update_cursor(direction)
    row, col = @cursor[0] + direction[0], @cursor[1] + direction[1]
    @cursor = [row, col].map { |coord| clamp(coord) }
  end

  def get_cursor_position
    @cursor
  end

  def clamp(coord)
    [0, [coord, 7].min].max
  end

  def render(color)
    system("clear")
    piece_at_cursor = @board.piece_at(@cursor)
    valid_moves = piece_at_cursor.moves.select{ |move| @board.is_valid_move?(piece_at_cursor,move)}
    display_grid = @board.get_icons
    puts "    #{("A".."H").to_a.join("  ")} "
    display_grid.each_with_index do |row, i|
      print " #{8 - i} "
      row.each_with_index do |icon, j|
        curr_pos = [i, j]
        icon_string = " #{icon} "
        if curr_pos == @cursor
          print icon_string.on_green
        elsif valid_moves.include?(curr_pos)
          print icon_string.on_yellow
        else
          print icon_string.colorize(:background => BG_COLORS[(i + j) % 2])
        end
      end
      print " #{8 - i} "
      case i
      when 0
        print " " + @board.get_captured_pieces(:white).map(&:get_icon).join(" ")
      when 4
        print "Check!" if @board.in_check?(color)
      when 7
        print " " + @board.get_captured_pieces(:black).map(&:get_icon).join(" ")
      end
      puts
    end
    puts "    #{("A".."H").to_a.join("  ")} "
    puts "#{color.to_s.capitalize}'s turn!"

  end
end

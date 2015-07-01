require_relative 'board'
require 'colorize'

class Display

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
    valid_moves = piece_at_cursor.moves

    display_grid = @board.get_icons
    display_grid.each_with_index do |row, i|
      row.each_with_index do |icon, j|
        curr_pos = [i, j]

        if curr_pos == @cursor
          print icon.colorize(:red) + " "
        elsif valid_moves.include?(curr_pos)
          print icon.colorize(:blue) + " "
        else
          print icon + " "
        end
      end
      puts
    end
    puts "#{color.to_s.capitalize}'s turn!"

  end
end

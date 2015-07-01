require 'byebug'
require_relative 'board'
require_relative 'display'
require_relative 'human_player'
require 'io/console'

class ChessGame
  attr_reader :board

  def initialize(*players)
    @board = Board.new
    @display = Display.new(@board)
    @selected_piece
    @display.render(:white)
    @players = [*players]
  end

  def run
    until over?
      get_source
      if move_to_destination
        @players.rotate!
        @display.render(current_player.get_color)
      end
    end
    puts "The game is over! #{Board.opposite_color(current_player.get_color).capitalize} wins!"
  end

  def current_player
    @players.first
  end

  def move_to_destination
    destination = current_player.get_destination(@display)
    return false unless is_valid_destination?(destination)
    @board.move_piece!(@selected_piece, destination)
    @display.render(current_player.get_color)
    @selected_piece = nil
    true
  end

  def is_valid_destination?(pos)
    return false unless pos
    @board.is_valid_move?(@selected_piece, pos)
  end

  def get_source
    piece = nil
    source = nil
    until piece && is_valid_piece?(piece)
      source = current_player.get_source(@display)
      piece = @board[source]
    end
    @selected_piece = piece
  end

  def is_valid_piece?(piece)
    return false if piece.is_a? EmptySquare
    piece.get_color == current_player.get_color
  end

  def over?
    @board.checkmate?(current_player.get_color)
  end
end

player1 = HumanPlayer.new(:white)
player2 = HumanPlayer.new(:black)
g = ChessGame.new(player1, player2)
# g.board[[7, 2]] = EmptySquare.new(nil, nil, [7, 2])
# g.board[[7, 3]] = EmptySquare.new(nil, nil, [7, 3])
# g.board[[7, 1]] = EmptySquare.new(nil, nil, [7, 1])
# g.board[[7, 5]] = EmptySquare.new(nil, nil, [7, 5])
# g.board[[7, 6]] = EmptySquare.new(nil, nil, [7, 6])
# g.board[[0, 2]] = EmptySquare.new(nil, nil, [0, 2])
# g.board[[0, 3]] = EmptySquare.new(nil, nil, [0, 3])
# g.board[[0, 1]] = EmptySquare.new(nil, nil, [0, 1])
# g.board[[0, 5]] = EmptySquare.new(nil, nil, [0, 5])
# g.board[[0, 6]] = EmptySquare.new(nil, nil, [0, 6])
g.run

module Slideable
  def moves_from(pos, diffs, board)
    moves = []
    diffs.each do |direction|
      moves += moves_in_direction(pos, direction, board)
    end
    moves
  end

  def moves_in_direction(pos, direction, board)
    curr_pos = pos.dup
    drow, dcol = direction
    moves = []
    while Board.is_valid?(curr_pos)
      case board.color_at(curr_pos)
      when nil
        moves << curr_pos.dup
      when self.get_color
        break unless curr_pos == pos
      else
        #p "adding because else-case, then breaking"
        moves << curr_pos.dup
        break
      end
      curr_pos[0] += drow
      curr_pos[1] += dcol
    end
    # drops our piece's actual position
    moves
  end
end

module Steppable
  def moves_from(pos, diffs, board)
    moves = []
    diffs.each do |direction|
      new_pos = [pos[0] + direction[0], pos[1] + direction[1]]
      moves << new_pos if Board.is_valid?(new_pos) && board.color_at(new_pos) != self.get_color
    end
    moves
  end
end

module Pawnable
  def moves_from(pos, diffs, board, moved)
    moves = []
    diffs.each do |move_type, diff|
      new_pos = [pos[0] + diff[0], pos[1] + diff[1]]
      next unless Board.is_valid?(new_pos)

      case move_type
      when :single_forward
        moves << new_pos unless board.color_at(new_pos)
      when :double_forward
        single_diff = diffs[:single_forward]
        single_forward = [pos[0] + single_diff[0], pos[1] + single_diff[1]]
        cannot_move = moved || board.color_at(single_forward) || board.color_at(new_pos)
        moves << new_pos unless cannot_move
      when :left_capture, :right_capture
        moves << new_pos if board.color_at(new_pos) == Board.opposite_color(self.get_color)
      end
    end
    moves
  end
end

class Piece
  def initialize(color,position,board)
    @color = color
    @position = position
    @board = board
    @icon = nil
  end

  def get_icon
    @icon
  end

  def get_color
    @color
  end

  def get_position
    @position
  end

  def set_position(position)
    @position = position
  end

  def moves
    raise "No piece type"
  end

  def is_valid_move?(pos)
    moves.include?(pos)
  end

  def dup
    Piece.new(@color, @position, @board)
  end
end

class Pawn < Piece
  include Pawnable

  def initialize(color, position, board)
    super
    @icon = color == :black ? "\u2659" : "\u265F"
    @moved = false
    if color == :black
      @diffs = {
          :single_forward => [1,0],
          :double_forward => [2,0],
          :left_capture => [1,-1],
          :right_capture => [1,1]
        }
    else
      @diffs = {
          :single_forward => [-1,0],
          :double_forward => [-2,0],
          :left_capture => [-1,-1],
          :right_capture => [-1,1]
        }
    end
  end

  def set_moved(moved)
    @moved = moved
  end

  def dup
    pawn = Pawn.new(@color, @position, @board)
    pawn.set_moved(@moved)
    pawn
  end

  def moves
    moves_from(@position, @diffs, @board, @moved)
  end

  def set_position(pos)
    super
    @moved = true
  end
end

class Rook < Piece
  include Slideable

  DIFFS = [
    [1,0],
    [-1,0],
    [0,1],
    [0,-1]
  ]

  def initialize(color, position, board)
    super
    @icon = color == :black ? "\u2656" : "\u265C"
  end

  def moves
    moves_from(@position, DIFFS, @board)
  end

  def dup
    Rook.new(@color, @position, @board)
  end
end

class Bishop < Piece
  include Slideable

  DIFFS = [
    [1,1],
    [1,-1],
    [-1,1],
    [-1,-1]
  ]

  def initialize(color, position, board)
    super
    @icon = color == :black ? "\u2657" : "\u265D"
  end

  def moves
    moves_from(@position, DIFFS, @board)
  end

  def dup
    Bishop.new(@color, @position, @board)
  end
end

class Knight < Piece
  include Steppable

  DIFFS = [
    [1,2],
    [1,-2],
    [-1,2],
    [-1,-2],
    [-2,1],
    [-2,-1],
    [2,1],
    [2,-1]
  ]

  def initialize(color, position, board)
    super
    @icon = color == :black ? "\u2658" : "\u265E"
  end

  def moves
    moves_from(@position, DIFFS, @board)
  end

  def dup
    Knight.new(@color, @position, @board)
  end
end

class Queen < Piece
  include Slideable

  DIFFS = [
    [1,0],
    [-1,0],
    [0,1],
    [0,-1],
    [1,1],
    [1,-1],
    [-1,1],
    [-1,-1]
  ]

  def initialize(color, position, board)
    super
    @icon = color == :black ? "\u2655" : "\u265B"
  end

  def moves
    moves_from(@position, DIFFS, @board)
  end

  def dup
    Queen.new(@color, @position, @board)
  end
end

class King < Piece
  include Steppable
  DIFFS = [
    [1,0],
    [-1,0],
    [0,1],
    [0,-1],
    [1,1],
    [1,-1],
    [-1,1],
    [-1,-1]
  ]

  def initialize(color, position, board)
    super
    @icon = color == :black ? "\u2654" : "\u265A"
  end

  def moves
    moves_from(@position, DIFFS, @board)
  end

  def dup
    King.new(@color, @position, @board)
  end
end

class EmptySquare < Piece
  def initialize(color, position, board)
    super
    @icon = "_"
  end

  def moves
    []
  end

  def dup
    EmptySquare.new(@color, @position, @board)
  end
end

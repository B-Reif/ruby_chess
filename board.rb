require_relative 'piece'

class Board
  PIECES = [Rook, Knight, Bishop, Queen, King, Bishop, Knight, Rook]

  def self.is_valid?(pos)
    pos.all? { |coord| coord.between?(0, 7) }
  end

  def self.opposite_color(color)
    return :white if color == :black
    return :black if color == :white
    return nil
  end

  def get_piece(color,piece_type)
    @grid.flatten.each do |piece|
      if piece.is_a?(piece_type) && piece.get_color == color
        return piece
      end
    end
    nil
  end

  def get_pieces(color)
    @grid.flatten.select { |piece| piece.get_color == color}
  end

  def in_check?(color)
    king = get_piece(color, King)
    king_pos = king.get_position
    opposing_pieces = get_pieces(Board.opposite_color(color))
    opposing_pieces.each do |piece|
      return true if piece.moves.include?(king_pos)
    end
    false
  end

  def checkmate?(color)
    return false unless in_check?(color)
    result = true
    pieces = get_pieces(color)
    # For all of our pieces, ensure that no piece has a valid move
    pieces.all? { |piece| piece.moves.none? {|move| is_valid_move?(piece,move)} }
  end

  def initialize
    make_grid
  end

  def make_grid
    @grid = Array.new(8) { Array.new(8) }
    indices = (0...8).to_a
    indices.product(indices).map { |pos| self[pos] = EmptySquare.new(nil, pos, self)}
    setup
    @captured_pieces = Hash.new { |h,k| h[k] = [] }
  end

  def [](pos)
    @grid[pos[0]][pos[1]]
  end

  def []=(pos, piece)
    @grid[pos[0]][pos[1]] = piece
  end

  def setup
    setup_pieces(:black, 0)
    setup_pawns(:black, 1)
    setup_pawns(:white, 6)
    setup_pieces(:white, 7)
  end

  def setup_pieces(color,row)
    PIECES.each_with_index do | piece_type, i|
      self[[row, i]] = piece_type.new(color,[row,i],self)
    end
  end

  def setup_pawns(color,row)
    8.times { |i| self[[row, i]] = Pawn.new(color,[row, i],self) }
  end

  def get_icons
    @grid.map { |row| row.map(&:get_icon) }
  end

  def piece_at(pos)
    self[pos]
  end

  def color_at(pos)
    self[pos].get_color
  end

  def move_piece(piece, destination)
    move(piece, destination)
  end

  def move_piece!(piece, destination)
    captured_piece = self[destination].dup
    source_pos = piece.get_position
    move(piece, destination)
    castle_if_necessary(source_pos, piece, destination)
    @captured_pieces[captured_piece.get_color] << captured_piece if captured_piece.to_valid_piece
  end

  private
  def move(piece, destination)
    source_pos = piece.get_position
    self[source_pos] = EmptySquare.new(nil, source_pos, self)
    piece.set_position(destination)
    self[destination] = piece
  end

  def castle_if_necessary(source_pos, piece, destination)
    diff = destination[1] - source_pos[1]
    return false unless piece.is_a?(King) && diff.abs == 2

    left_square = self[[destination[0], destination[1]-2]].to_valid_piece
    right_square = self[[destination[0], destination[1]+1]].to_valid_piece
    rook = left_square || right_square
    rook_destination = [destination[0], destination[1] + (diff > 0 ? -1 : +1)]
    move_piece(rook,rook_destination)
  end

  public
  def is_valid_move?(piece, destination)
    return false unless piece.is_valid_move?(destination)
    piece_to_move = piece.dup
    target_pos = destination.dup
    target_piece = self[target_pos].dup

    move_piece(piece_to_move, target_pos)
    is_valid = !in_check?(piece.get_color)
    self[piece.get_position] = piece
    self[target_pos] = target_piece
    is_valid
  end

  def positions_between(source, destination)
    # ONLY WORKS FOR COLUMNS
    result = []
    start = [source[1], destination[1]].min
    endpoint = [source[1],destination[1]].max
    (start+1...endpoint).each do |col|
      result << [source[0], col]
    end
    return result
  end

  def get_captured_pieces(color)
    raise "Invalid color" unless color == :black || color == :white
    @captured_pieces[color]
  end
end

class ComputerPlayer
  VALS = {
    King => 1000000,
    Queen => 925,
    Rook => 500,
    Bishop => 325,
    Knight => 300,
    Pawn => 100
  }

  def initialize(color,board)
    @color = color
    @board = board
  end

  def get_source(display)
    move_hash = {}
    @board.get_pieces(@color).each do |piece|
      move_hash[piece] = piece.moves
    end

    capture_hash = Hash.new { |h,v| h[v] = []}
    move_hash.each do |piece, moves|
      moves.each do |move|
        capture_hash[piece] << move if @board.color_at(move) == Board.opposite_color(@color)
      end
    end

    if capture_hash.size == 0
      random_move
      @move = @selected_piece.moves.sample
    else
      max_val = 0
      capture_hash.each do |piece, moves|
        moves.each do |move|
          if VALS[@board.piece_at(move).class] > max_val
            max_val = VALS[@board.piece_at(move).class]
            @move = move
            @selected_piece = piece
          end
        end
      end
    end

    @selected_piece.get_position
  end

  def random_move
    @selected_piece = @board.get_pieces(@color).sample
    @selected_piece.get_position
  end

  def get_destination(display)
    @move
  end

  def get_color
    @color
  end

end

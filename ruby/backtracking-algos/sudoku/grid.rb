class Grid

  SQUARE_SIZE = 3
  DEFAULT_MATRIX_SIZE = SQUARE_SIZE**2

  attr_reader :board

  def initialize(file_name)
    @board = Array.new(DEFAULT_MATRIX_SIZE, false) do
      Array.new(DEFAULT_MATRIX_SIZE, false)
    end
    open(file_name) { |fn| parse(fn.read) }
  end

  def size
    return DEFAULT_MATRIX_SIZE
  end

  def parse(string_puzzle)
    count = 0
    current_row = -1
    string_puzzle.strip.gsub(/\n/, "").chars.each do |char|
      if count % DEFAULT_MATRIX_SIZE == 0
        current_row +=1
      end
      @board[current_row][count % DEFAULT_MATRIX_SIZE] = val(char)
      count +=1
    end
  end
  private :parse

  def no_conflicts?(row, col, new_number)
    return (col_ok?(col, new_number) &&
      row_ok?(row, new_number) &&
      square_ok?(row-row%SQUARE_SIZE, col-col%SQUARE_SIZE, new_number)
    )
  end

  def add_number(row, col, new_number)
    @board[row][col] = new_number
  end

  def remove_number(row, col)
    @board[row][col] = false
  end

  def find_free_positions
    DEFAULT_MATRIX_SIZE.times do |row|
      DEFAULT_MATRIX_SIZE.times do |col|
        if @board[row][col] == false
          return [row, col]
        end
      end
    end
  end

  def square_ok?(start_row, start_col, new_number)
    (DEFAULT_MATRIX_SIZE/SQUARE_SIZE).times do |row|
      (DEFAULT_MATRIX_SIZE/SQUARE_SIZE).times do |col|
        if @board[start_row+row][start_col+col] == new_number
          return false
        end
      end
    end
    return true
  end

  def col_ok?(col, new_number)
    DEFAULT_MATRIX_SIZE.times do |row|
      if @board[row][col] == new_number
        return false
      end
    end
    return true
  end

  def row_ok?(row, new_number)
    DEFAULT_MATRIX_SIZE.times do |col|
      if @board[row][col] == new_number
        return false
      end
    end
    return true
  end

  def encoding
    board.flatten.map { |cell| cell || "." }.join
  end

  def print!
    puts encoding.gsub(/.../, "\\0 ").
      gsub(/.{12}/, "\\0\n").
      gsub(/.{39}/m, "\\0\n").
      gsub(/[\d.]/, "\\0 ")
  end

  def val(char)
    return ((char == '.') ?  false : char.to_i)
  end
end

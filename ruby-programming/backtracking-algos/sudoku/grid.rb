class Grid
	
	DEFAULT_MATRIX_SIZE = 9
	
	attr_reader :board

	def initialize(file_name)
		@board = Array.new(DEFAULT_MATRIX_SIZE, false) do
			Array.new(DEFAULT_MATRIX_SIZE, false) 
		end

		open(file_name) do |fn|
			parse(fn.read)
		end
	end

	def size
		return DEFAULT_MATRIX_SIZE
	end

	def parse(string_puzzle)
		count = 0
		current_row = -1
		string_puzzle.strip.gsub(/\n/, "").split("").each do |char|
			if count % DEFAULT_MATRIX_SIZE == 0
				current_row +=1
			end
			@board[current_row][count % DEFAULT_MATRIX_SIZE] = val(char)
			count +=1
		end
	end

	def no_conflicts?(row, col, new_number)
		return (col_ok?(col, new_number) and 
			row_ok?(row, new_number) and 
			square_ok?(row-row%3, col-col%3, new_number) )
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
		return nil
	end

	def square_ok?(start_row, start_col, new_number)
		(DEFAULT_MATRIX_SIZE/3).times do |row|
			(DEFAULT_MATRIX_SIZE/3).times do |col|
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

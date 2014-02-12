class Board

	attr_reader :board, :rows

	def initialize(rows)
		@rows = rows
		@board = Array.new(rows,0) { Array.new(rows,0) }
		p "Board Initialized..."
		sleep 1
	end

	def find_free_column
		@rows.times do |col|
			if column_ok?(col)
				return col
			end
		end
		return nil
	end

	def add_piece(row, col)
		return @board[row][col] = 1
	end

	def remove_piece(row, col)
		return @board[row][col] = 0
	end

	def occupied?(row, col)
		return @board[row][col] == 1
	end

	def is_safe(row, col)
		return ( upper_diagonal_ok?(row, col) and row_ok?(row, col) and lower_diagonal_ok?(row, col) )
	end

	def row_ok?(row, col)
		return true if col == 0
		return (@board[row].take(col).reduce(:+) == 0)
	end

	def column_ok?(col)
		return (@board.map {|r| r[col] }.reduce(:+) == 0)
	end

	def upper_diagonal_ok?(row, col)
		while col >= 0 and row < rows do
			if occupied?(row,col)
				return false
			end
			row += 1
			col -= 1
		end
		return true
	end

	def lower_diagonal_ok?(row, col)
		while row >= 0 and col >= 0 do
			if occupied?(row,col)
				return false
			end
			row -= 1
			col -= 1
		end
		return true
	end

	def print!
		(@rows).times do |row|
			print "\n|"
			(@rows).times do |col|
				print " #{occupied?(row,col) ? 'Q' : ' '} |"
			end
		end
		print "\n"
	end
end

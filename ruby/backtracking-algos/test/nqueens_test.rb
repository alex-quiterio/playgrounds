require 'minitest/autorun'
require_relative '../backtracking_algorithm'
require_relative '../n-queens/nqueens'

class NQueensTest < Minitest::Test
  # Known number of boards, from OEIS A000170, decides solvability.
  SOLVABLE = { 1 => true, 2 => false, 3 => false, 4 => true, 5 => true, 6 => true, 8 => true }.freeze

  def solve(n)
    problem = NQueens.new(n)
    solved = BacktrackingAlgorithm.new(problem).solve(problem)
    [solved, problem.board]
  end

  def queens(board)
    board.rows.times.flat_map do |row|
      board.rows.times.select { |col| board.occupied?(row, col) }.map { |col| [row, col] }
    end
  end

  def assert_valid_placement(board)
    placed = queens(board)
    assert_equal board.rows, placed.size, 'one queen per column'
    assert_equal board.rows, placed.map(&:first).uniq.size, 'one queen per row'
    assert_equal board.rows, placed.map { |r, c| r - c }.uniq.size, 'no shared diagonal'
    assert_equal board.rows, placed.map { |r, c| r + c }.uniq.size, 'no shared anti-diagonal'
  end

  SOLVABLE.each do |n, solvable|
    define_method("test_#{n}_queens_#{solvable ? 'has' : 'has_no'}_solution") do
      solved, board = solve(n)
      assert_equal solvable, solved
      if solvable
        assert_valid_placement(board)
      else
        assert_empty queens(board), 'board is restored after a failed search'
      end
    end
  end

  def test_first_four_queens_solution
    _, board = solve(4)
    assert_equal [[0, 0, 1, 0], [1, 0, 0, 0], [0, 0, 0, 1], [0, 1, 0, 0]], board.board
  end

  def test_find_free_column_is_nil_when_every_column_has_a_queen
    board = Board.new(2)
    assert_equal 0, board.find_free_column
    board.add_piece(0, 0)
    assert_equal 1, board.find_free_column
    board.add_piece(1, 1)
    assert_nil board.find_free_column
  end

  def test_is_safe_checks_row_and_both_diagonals_to_the_left
    board = Board.new(4)
    board.add_piece(1, 0)
    refute board.is_safe(1, 2), 'same row'
    refute board.is_safe(2, 1), 'lower-left diagonal'
    refute board.is_safe(0, 1), 'upper-left diagonal'
    assert board.is_safe(3, 1)
  end

  def test_print_draws_the_board
    problem = NQueens.new(2)
    problem.mark_iteration(0, 1)
    assert_output("\n|   | Q |\n|   |   |\n") { problem.print }
  end
end

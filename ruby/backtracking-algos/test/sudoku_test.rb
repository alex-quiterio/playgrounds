require 'minitest/autorun'
require 'tempfile'
require_relative '../backtracking_algorithm'
require_relative '../sudoku/sudoku'

class SudokuTest < Minitest::Test
  PUZZLES = File.expand_path('../sudoku/puzzles', __dir__)

  def puzzle(name)
    File.join(PUZZLES, "#{name}.sud")
  end

  def solve(name)
    problem = Sudoku.new(puzzle(name))
    solved = BacktrackingAlgorithm.new(problem).solve(problem)
    [solved, problem.grid]
  end

  def assert_valid_solution(grid, original)
    rows = grid.board
    digits = (1..9).to_a
    rows.each { |row| assert_equal digits, row.sort }
    rows.transpose.each { |col| assert_equal digits, col.sort }
    [0, 3, 6].product([0, 3, 6]).each do |r, c|
      assert_equal digits, rows[r, 3].flat_map { |row| row[c, 3] }.sort
    end
    original.chars.zip(grid.encoding.chars).each do |given, solved|
      assert_equal given, solved unless given == '.'
    end
  end

  def test_parses_the_puzzle_file
    grid = Grid.new(puzzle('easy01'))
    assert_equal '79....3.......69..8...3..76.....5..2..54187..4..7.....61..9...8..23.......9....54',
                 grid.encoding
  end

  def test_parses_files_with_windows_line_endings
    assert_equal Grid.new(puzzle('wiki')).encoding, Grid.new(puzzle('wiki_dos')).encoding
  end

  def test_no_conflicts_checks_row_column_and_square
    grid = Grid.new(puzzle('easy01'))
    refute grid.no_conflicts?(0, 2, 7), 'row already has 7'
    refute grid.no_conflicts?(1, 0, 8), 'column already has 8'
    refute grid.no_conflicts?(1, 1, 9), 'square already has 9'
    assert grid.no_conflicts?(0, 2, 1)
  end

  def test_find_free_positions_is_nil_on_a_full_grid
    _, grid = solve('easy01')
    assert_nil grid.find_free_positions
  end

  %w[easy01 easy02 medium hard wiki wiki_dos expert01 extreme01 standard01 empty].each do |name|
    define_method("test_solves_#{name}") do
      original = Grid.new(puzzle(name)).encoding
      solved, grid = solve(name)
      assert solved, "#{name} should be solvable"
      assert_valid_solution(grid, original)
    end
  end

  def test_unsolvable_grid_is_reported
    # The last cell of the first row has no candidate: 1-8 are in its row, 9 in its column.
    Tempfile.create(['broken', '.sud']) do |file|
      file.write("12345678.\n........9\n" + ".........\n" * 7)
      file.flush
      problem = Sudoku.new(file.path)
      refute BacktrackingAlgorithm.new(problem).solve(problem)
    end
  end
end

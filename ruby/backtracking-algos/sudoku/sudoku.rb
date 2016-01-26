require 'forwardable'
require_relative '../problem'
require_relative 'grid'

class Sudoku < Problem
  extend Forwardable

  attr_reader :grid
  def_delegator :@grid, :print!, :print
  def_delegator :@grid, :find_free_positions, :find_new_coords

  def initialize(file_name)
    @grid = Grid.new(file_name)
  end

  def is_safe?(val, num)
    @grid.no_conflicts?(num[0], num[1], val)
  end

  def mark_iteration(val, num)
    @grid.add_number(num[0], num[1], val)
  end

  def unmark_iteration(val, num)
    @grid.remove_number(num[0], num[1])
  end

  def iteration_counter
    return (1..@grid.size)
  end
end

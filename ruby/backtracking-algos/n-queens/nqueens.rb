require 'forwardable'
require_relative 'board'
require_relative '../problem'

class NQueens < Problem
  extend Forwardable

  attr_reader :board
  def_delegator :@board, :add_piece, :mark_iteration
  def_delegator :@board, :remove_piece, :unmark_iteration
  def_delegator :@board, :find_free_column, :find_new_coords
  def_delegator :@board, :is_safe, :is_safe?
  def_delegator :@board, :print!, :print

  def initialize(rows)
    @board = Board.new(rows)
    @memorized_values = [-1]
  end

  def iteration_counter
    return (0..(@board.rows-1))
  end
end

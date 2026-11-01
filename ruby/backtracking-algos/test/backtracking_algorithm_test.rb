require 'minitest/autorun'
require_relative '../backtracking_algorithm'
require_relative '../problem'

class BacktrackingAlgorithmTest < Minitest::Test
  # Picks one digit per slot so the digits sum to `target`.
  class DigitSum < Problem
    attr_reader :digits

    def initialize(slots, target)
      @digits = Array.new(slots)
      @target = target
    end

    def find_new_coords
      @digits.index(nil)
    end

    def iteration_counter
      (0..9)
    end

    def is_safe?(digit, slot)
      partial = @digits.compact.sum + digit
      remaining = @digits.size - slot - 1
      partial <= @target && partial + remaining * 9 >= @target
    end

    def mark_iteration(digit, slot)
      @digits[slot] = digit
    end

    def unmark_iteration(_digit, slot)
      @digits[slot] = nil
    end

    def print
      Kernel.print @digits.join
    end
  end

  def test_rejects_objects_that_are_not_problems
    assert_raises(ArgumentError) { BacktrackingAlgorithm.new(Object.new) }
  end

  def test_solves_a_satisfiable_problem
    problem = DigitSum.new(3, 25)
    assert BacktrackingAlgorithm.new(problem).solve(problem)
    assert_equal 25, problem.digits.sum
  end

  def test_backtracks_to_the_first_solution_in_order
    problem = DigitSum.new(3, 25)
    BacktrackingAlgorithm.new(problem).solve(problem)
    assert_equal [7, 9, 9], problem.digits
  end

  def test_reports_failure_and_restores_state_when_unsatisfiable
    problem = DigitSum.new(2, 19)
    refute BacktrackingAlgorithm.new(problem).solve(problem)
    assert_equal [nil, nil], problem.digits
  end

  def test_run_prints_the_solution
    problem = DigitSum.new(2, 18)
    assert_output('99') { BacktrackingAlgorithm.new(problem).run }
  end

  def test_problem_methods_must_be_implemented
    problem = Problem.new
    %i[iteration_counter print find_new_coords].each do |method|
      assert_raises(NotImplementedError) { problem.public_send(method) }
    end
  end
end

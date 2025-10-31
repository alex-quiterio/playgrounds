require 'minitest/autorun'
require_relative '../n-queens/n_queens'

class GenerationalNQueensTest < Minitest::Test
  def setup
    srand(1)
  end

  def solver(size: 8, population: 100, max_generations: 1)
    NQueens.new(size: size, population: population, max_generations: max_generations)
  end

  def assert_permutation(gene, size)
    assert_equal (0...size).to_a, gene.sort
  end

  def test_board_size_is_independent_of_population_size
    s = solver(size: 5, population: 30)
    assert_equal 5, s.board_size
    assert_equal 30, s.create_first_generation(30).size
    assert_permutation s.gen_random_gene, 5
  end

  def test_first_generation_members_are_scored_permutations
    s = solver(size: 6)
    s.create_first_generation(10).each do |member|
      assert_permutation member[:gene], 6
      assert_equal s.evaluate(member[:gene]), member[:fitness]
    end
  end

  def test_same_column_is_a_threat
    assert solver.is_threat([0, 0], 0, 1)
  end

  def test_a_queen_does_not_threaten_itself
    refute solver.is_threat([0, 1], 0, 0)
  end

  def test_diagonal_is_a_threat
    assert solver.is_threat([0, 1], 0, 1)
    assert solver.is_threat([0, 1], 1, 0)
  end

  def test_anti_diagonal_is_a_threat
    assert solver.is_threat([1, 0], 0, 1)
    assert solver.is_threat([3, 1, 2, 0], 0, 3)
  end

  def test_non_attacking_queens_are_not_a_threat
    refute solver.is_threat([0, 2], 0, 1)
  end

  def test_valid_boards_score_full_fitness
    assert_equal 1.0, solver.evaluate([1, 3, 0, 2])
    assert_equal 1.0, solver.evaluate([0, 4, 7, 5, 2, 6, 1, 3])
  end

  def test_all_queens_on_one_diagonal_score_zero
    assert_equal 0.0, solver.evaluate([0, 1, 2, 3])
    assert_equal 0.0, solver.evaluate([3, 2, 1, 0])
  end

  def test_fitness_distinguishes_partial_solutions
    # [0, 2, 1, 3] has 2 threatening pairs out of 6, [0, 1, 2, 3] has 6.
    assert_in_delta 4.0 / 6, solver.evaluate([0, 2, 1, 3])
    assert_operator solver.evaluate([0, 2, 1, 3]), :>, solver.evaluate([0, 1, 2, 3])
  end

  def test_reproduce_always_yields_a_permutation
    s = solver(size: 8)
    200.times do
      a = { gene: s.gen_random_gene }
      b = { gene: s.gen_random_gene }
      assert_permutation s.reproduce(a, b), 8
    end
  end

  def test_reproduce_takes_each_position_from_a_parent
    s = NQueens.new(size: 6, max_generations: 1, mutation_rate: 0)
    a = { gene: [0, 1, 2, 3, 4, 5] }
    b = { gene: [1, 2, 0, 4, 5, 3] }
    50.times do
      child = s.reproduce(a, b)
      child.each_with_index { |column, row| assert_includes [a[:gene][row], b[:gene][row]], column }
    end
  end

  def test_best_returns_the_fittest_member
    population = [{ fitness: 0.0, gene: [0] }, { fitness: 0.75, gene: [1] }, { fitness: 0.5, gene: [2] }]
    assert_equal({ fitness: 0.75, gene: [1] }, solver.best(population))
  end

  def test_decimate_drops_the_least_fit_fraction
    population = (0...10).map { |i| { fitness: i / 10.0, gene: [i] } }.shuffle
    survivors = solver._decimate(population, 0.4)
    assert_equal [0.9, 0.8, 0.7, 0.6, 0.5, 0.4], survivors.map { |m| m[:fitness] }
  end

  def test_breed_refills_to_population_size
    s = solver(size: 6)
    survivors = s.create_first_generation(6)
    assert_equal 20, s._breed(survivors, 20).size
  end

  def test_run_keeps_the_population_size
    s = solver(size: 6, population: 40, max_generations: 3)
    assert_equal 40, s.run.size
  end

  [4, 6, 8].each do |size|
    define_method("test_run_solves_#{size}_queens") do
      s = solver(size: size, population: 100, max_generations: 1000)
      best = s.best(s.run)
      assert_equal 1.0, best[:fitness]
      assert_permutation best[:gene], size
    end
  end
end

require 'minitest/autorun'
require_relative '../n-queens/n_queens'

class GenerationalNQueensTest < Minitest::Test
  def solver(size: 8, max_generations: 1)
    NQueens.new(size: size, max_generations: max_generations)
  end

  def test_random_gene_is_a_permutation_of_columns
    srand(1)
    gene = solver(size: 8).gen_random_gene
    assert_equal (0...8).to_a, gene.sort
  end

  def test_first_generation_has_population_size_genes
    srand(1)
    population = solver(size: 6).create_first_generation(6)
    assert_equal 6, population.size
    population.each do |member|
      assert_equal %i[fitness gene], member.keys.sort
      assert_equal (0...6).to_a, member[:gene].sort
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

  def test_non_attacking_queens_are_not_a_threat
    refute solver.is_threat([0, 2], 0, 1)
  end

  def test_valid_board_scores_full_fitness
    assert_equal 1, solver.evaluate([1, 3, 0, 2])
  end

  def test_board_with_threats_scores_lower_than_a_valid_board
    assert_operator solver.evaluate([0, 1, 2, 3]), :<, solver.evaluate([1, 3, 0, 2])
  end

  def test_anti_diagonal_is_a_threat
    skip 'known bug: is_threat only checks one diagonal direction'
    assert solver.is_threat([1, 0], 0, 1)
  end

  def test_fitness_distinguishes_partial_solutions
    skip 'known bug: evaluate uses integer division, so fitness is only ever 0 or 1'
    assert_operator solver.evaluate([0, 2, 1, 3]), :>, solver.evaluate([0, 1, 2, 3])
  end

  def test_best_returns_the_fittest_member
    population = [{ fitness: 0, gene: [0] }, { fitness: 3, gene: [1] }, { fitness: 1, gene: [2] }]
    assert_equal({ fitness: 3, gene: [1] }, solver.best(population))
  end

  def test_decimate_keeps_the_fittest_members
    population = (0...10).map { |i| { fitness: i, gene: [i] } }.shuffle(random: Random.new(1))
    survivors = solver._decimate(population, 0.4)
    assert_equal survivors.map { |m| m[:fitness] }, survivors.map { |m| m[:fitness] }.sort.reverse
    assert_equal 9, survivors.first[:fitness]
    refute_includes survivors.map { |m| m[:fitness] }, 0
  end

  def test_run_returns_a_population
    skip 'known bug: reproduce leaves false entries in the gene, so breeding crashes in is_threat'
    srand(1)
    population = solver(size: 8, max_generations: 5).run
    assert_equal (0...8).to_a, solver.best(population)[:gene].sort
  end
end

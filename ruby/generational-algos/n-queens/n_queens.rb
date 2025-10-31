class Solver
  attr_reader :population

  def initialize(options)
    @population      = []
    @max_generations = options.fetch(:max_generations)
    @decimation      = options.fetch(:decimation, 0.4)
    @population_size = options.fetch(:population, 100)
  end

  def best(population)
    _sort_population(population).first
  end

  # Breeds generations until a perfect member appears or max_generations is reached.
  def run
    population = create_first_generation(@population_size)
    @max_generations.times do
      break if best(population)[:fitness] >= 1
      population = _breed(_decimate(population, @decimation), @population_size)
    end
    population
  end

  def create_first_generation(population_size)
    population_size.times.map { _create_gene(gen_random_gene) }
  end

  def _sort_population(population)
    population.sort_by { |member| -member[:fitness] }
  end

  # Keeps the fittest members, dropping the `decimation` fraction that scored lowest.
  def _decimate(population, decimation)
    population = _sort_population(population)
    kill = (decimation * population.length).ceil
    population.first([population.length - kill, 2].max)
  end

  # Refills the population up to `size` with children of random survivors.
  def _breed(population, size)
    population + (population.length...size).map do
      _create_gene(reproduce(_select(population), _select(population)))
    end
  end

  def _create_gene(gene)
    { fitness: evaluate(gene), gene: gene }
  end

  def _select(population)
    population[rand(population.length)]
  end
end

# A gene is a permutation: gene[row] is the column of the queen in that row,
# so rows and columns never clash and only diagonals have to be checked.
class NQueens < Solver
  attr_reader :board_size

  def initialize(options)
    super
    @board_size    = options.fetch(:size, 8)
    @mutation_rate = options.fetch(:mutation_rate, 0.2)
  end

  def gen_random_gene
    (0...@board_size).to_a.shuffle
  end

  # Cycle crossover: copies one cycle of positions from parent A and the rest
  # from parent B, so the child is always a valid permutation.
  def reproduce(gene_a, gene_b)
    a = gene_a[:gene]
    b = gene_b[:gene]
    child = Array.new(a.size)
    position = rand(a.size)
    until child[position]
      child[position] = a[position]
      position = a.index(b[position])
    end
    b.each_with_index { |column, row| child[row] ||= column }
    mutate(child)
  end

  # Swaps two rows with probability mutation_rate, keeping the permutation valid.
  def mutate(gene)
    return gene unless rand < @mutation_rate

    i = rand(gene.size)
    j = rand(gene.size)
    gene[i], gene[j] = gene[j], gene[i]
    gene
  end

  # Fitness in [0, 1]: 1 means no two queens threaten each other.
  def evaluate(gene)
    pairs = gene.size * (gene.size - 1) / 2
    return 1.0 if pairs.zero?

    threats = gene.each_index.to_a.combination(2).count { |i, j| is_threat(gene, i, j) }
    (pairs - threats).fdiv(pairs)
  end

  def is_threat(gene, i, j)
    return false if i == j
    return true if gene[i] == gene[j]

    (gene[i] - gene[j]).abs == (i - j).abs
  end
end

class Solver
  attr_reader :population
  def initialize(options)
    @population      = []
    @max_generations = options.fetch(:max_generations)
    @decimation      = options.fetch(:decimation, 0.4)
    @population_size = options.fetch(:size, 100)
  end

  def best(population)
    _sort_population(population).first
  end

  def run
    decimation = @decimation
    max_gens   = @max_generations
    ->(population) {
      size = population.length
      max_gens.times {
        population = _breed(_decimate(population, decimation), size)
      }
      population
    }.call(create_first_generation(@population_size))
  end

  def create_first_generation(population_size)
    population_size.times.map { _create_gene(gen_random_gene) }
  end

  def _sort_population(population)
    population.sort { |a,b| b[:fitness] - a[:fitness] }
  end

  def _decimate(population, decimation)
    population = _sort_population(population)
    kill = (decimation * population.length).ceil
    population.slice(0, population.length - kill + 1)
  end

  def _breed(population, size)
    population + (population.length..size).map do
      _create_gene(reproduce(_select(population), _select(population)))
    end
  end

  def _create_gene(gene)
    { fitness: evaluate(gene), gene: gene }
  end

  def _select(population)
    population[(population.length * rand).floor]
  end
end

class NQueens < Solver
  def gen_random_gene
    gene = Array.new(@population_size);
    gene.size.times do |i|
      gene[i] = i
    end
    gene.size.times do |i|
      holder = (rand * gene.size).floor
      gene[i], gene[holder] = gene[holder], gene[i]
    end
    return gene
  end

  def reproduce(geneA, geneB)
    new_gene   = ([false] * geneA[:gene].size)
    _next      = (rand * new_gene.size).floor
    while new_gene[_next] == false
      new_gene[_next] = geneA[:gene][_next]
      _next = geneA[:gene].find_index do |crox|
        break if crox == geneB[:gene][_next]
      end || (new_gene.length - 1)
    end
    geneB[:gene].each_with_index do |ix, crox|
      new_gene[ix] ||= crox
    end
    return new_gene
  end

  def evaluate(gene)
    threats = 0
    gene.size.times do |i|
      gene.size.times do |j|
        threats += 1 if is_threat(gene, i,j)
      end
    end
    max_threats = gene.size * (gene.size - 1)
    return (max_threats - threats) / max_threats
  end

  def is_threat(gene, i, j)
    return false if i == j
    return true if gene[i] == gene[j]
    former = [i, j].min
    latter = [i, j].max
    return (gene[latter] - gene[former]) == (latter - former)
  end
end

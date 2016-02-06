class Solver
  attr_reader :population
  def initialize(options)
    @population      = []
    @decimation      = options.fetch(:decimation)
    @population_size = options.fetch(:population_size)
    @max_generations = options.fetch(:max_generations)
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
    population_size.times.map { gen_random_gene }
  end

  def _sort_population(population)
    population.sort { |a,b| b.fitness - a.fitness }
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
    population[(population.length * gen_random_gene).floor]
  end
end

class NQueens < Solver
  def gen_random_gene
    gene = Array.new(@board_size);
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
    while !new_gene[_next]
      new_gene[_next] = geneA[:gene][_next]
      _next = geneA[:gene].find_index do |crox|
        break if crox == geneB[:gene][_next]
      end
    end
    geneB[:gene].each_with_index do |ix, crox|
      new_gene[ix] ||= crox
    end
    return new_gene
  end

  def evaluate
  end
end
# var assert = require('assert');
# var util = require('util');
# var Solver = require('./solver');

# module.exports = NQueens;

# util.inherits(NQueens, Solver);

# function NQueens(options) {
#   if (! (this instanceof NQueens))
#     return new NQueens(options);

#   assert(options, 'need options');
#   assert(options.boardSize, 'need options.boardSize');
#   assert(options.maxGenerations, 'need options.maxGenerations');

#   options.populationSize = options.populationSize || 100;
#   options.decimation = options.decimation || 0.2;

#   Solver.call(this, options);
# }

# NQueens.prototype.random = random;
# function random() {
#   var gene = new Array(this.options.boardSize);
#   var i, holder;

#   // create identity array
#   for(i = 0; i < gene.length; ++i)
#     gene[i] = i;

#   // randomly switch entries
#   for(i = 0; i < gene.length; ++i) {
#     j = Math.floor(Math.random() * gene.length);

#     holder = gene[j];
#     gene[j] = gene[i];
#     gene[i] = holder;
#   }

#   return gene;
# }

# NQueens.prototype.reproduct = reproduct;
# function reproduct(geneA, geneB) {
#   assert(geneA instanceof Array, 'gene must be an array');
#   assert(geneB instanceof Array, 'gene must be an array');
#   assert(geneA.length === geneB.length, 'genes must be compatible');

#   var size = geneA.length;
#   var geneNew = new Array(size);
#   var filled = new Array(size);

#   var next = Math.floor(Math.random() * size);
#   var i;

#   while(! filled[next]) {
#     geneNew[next] = geneA[next];
#     filled[next] = true;

#     for (i = 0; i < geneA.length; ++i)
#       if (geneA[i] === geneB[next])
#         break;

#     next = i;
#   }

#   for(i = 0; i < size; ++i)
#     if(! filled[i])
#       geneNew[i] = geneB[i];

#   return geneNew;
# }

# NQueens.prototype.evaluate = evaluate;
# function evaluate(gene) {
#   var board = gene;
#   var threats = 0;

#   var i, j;
#   for(i = 0; i < board.length; ++i)
#     for(j = 0; j < board.length; ++j)
#       if (mutualThreat(board, i, j))
#         ++threats;

#   var maxThreats = board.length * (board.length - 1);
#   debugger;
#   var fitness = (maxThreats - threats) / maxThreats;

#   return fitness;
# }

# function mutualThreat(board, columnA, columnB) {
#     if (columnB === columnA)
#       return false;

#     // check for horizontal threat
#     if (board[columnA] === board[columnB])
#       return true;

#     // check for diagonnal threat
#     var former = Math.min(columnA, columnB);
#     var latter = Math.max(columnA, columnB);
#     if(Math.abs(board[latter] - board[former]) === latter - former)
#       return true;
# }

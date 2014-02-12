class BacktrackingAlgorithm
	
	attr_accessor :problem

	def initialize(problem)
		unless problem.class.ancestors.include?(Problem)
			error = "#{self.class.to_s} should receive a Problem subclass as argument!"
			raise ArgumentError.new(error)
		end
		@problem = problem
	end
	
	def solve(problem)
		return true if problem.stop_condition?
		coords = problem.find_new_coords
		(problem.iteration_counter).each do |guess|
			if problem.is_safe?(guess, coords)
				problem.mark_iteration(guess, coords)
				return true if solve(problem)
				problem.unmark_iteration(guess, coords)
			end
		end
		return false
	end

	def run
		solve(@problem)
		@problem.print
	end
end

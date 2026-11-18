# frozen_string_literal: true

module HumanDesign
  # Given the set of active gate numbers (from both charts), works out which
  # channels are complete, which centers are defined, and how they connect.
  class BodyGraph
    def initialize(active_gate_numbers)
      @active_gate_numbers = active_gate_numbers.uniq
      @active_channels = Channel.all.select { |c| c.active?(@active_gate_numbers) }
      @defined_centers = @active_channels.flat_map(&:centers).uniq
      @adjacency = build_adjacency
    end

    attr_reader :active_gate_numbers, :active_channels, :defined_centers

    def undefined_centers
      Center::ALL - defined_centers
    end

    def hanging_gates
      @hanging_gates ||= active_gate_numbers.reject do |g|
        active_channels.any? { |c| c.includes_gate?(g) }
      end
    end

    def hanging_gates_by_center
      hanging_gates.group_by { |g| Center.containing(g) }
    end

    def connected?(from_center, to_center)
      return false unless defined_centers.include?(from_center)
      reachable_from(from_center).include?(to_center)
    end

    def components
      seen = []
      defined_centers.each_with_object([]) do |center, comps|
        next if seen.include?(center)
        comp = reachable_from(center)
        seen.concat(comp)
        comps << comp
      end
    end

    def definition_type
      case components.size
      when 0 then "No Definition"
      when 1 then "Single Definition"
      when 2 then "Split Definition"
      when 3 then "Triple Split Definition"
      when 4 then "Quadruple Split Definition"
      else "#{components.size}-Way Split Definition"
      end
    end

    def motor_connected_to_throat?
      return false unless defined_centers.include?("Throat")
      Center::MOTORS.any? { |m| defined_centers.include?(m) && connected?(m, "Throat") }
    end

    private

    def build_adjacency
      adj = Hash.new { |h, k| h[k] = [] }
      active_channels.each do |c|
        a, b = c.centers
        adj[a] << b
        adj[b] << a
      end
      adj
    end

    def reachable_from(start)
      seen = []
      stack = [start]
      until stack.empty?
        n = stack.pop
        next if seen.include?(n)
        seen << n
        @adjacency[n].each { |m| stack << m unless seen.include?(m) }
      end
      seen
    end
  end
end

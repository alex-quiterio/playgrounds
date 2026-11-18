# frozen_string_literal: true

module HumanDesign
  # All 13 planetary gate/line activations for one moment in time (either the
  # Personality/conscious chart or the Design/unconscious chart).
  class ActivationSet
    def initialize(jd, ephemeris)
      @jd = jd
      @gates_by_planet = Planet::ALL.each_with_object({}) do |name, hash|
        hash[name] = Planet.new(name).gate_at(jd, ephemeris)
      end
    end

    def gate_for(planet_name)
      @gates_by_planet.fetch(planet_name)
    end

    def sun_gate
      gate_for("Sun")
    end

    def each_gate(&block)
      @gates_by_planet.each(&block)
    end

    def gate_numbers
      @gates_by_planet.values.map(&:number).uniq
    end
  end
end

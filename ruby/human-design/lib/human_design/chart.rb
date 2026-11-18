# frozen_string_literal: true

module HumanDesign
  # The full reading: Type, Strategy, Authority, Profile, Definition — derived
  # from a BirthData's Personality and Design activation sets.
  class Chart
    STRATEGIES = {
      "Generator" => "To respond",
      "Manifesting Generator" => "To respond, then inform",
      "Manifestor" => "To inform before you act",
      "Projector" => "Wait for the invitation",
      "Reflector" => "Wait a lunar cycle before deciding"
    }.freeze

    NOT_SELF_THEMES = {
      "Generator" => "Frustration",
      "Manifesting Generator" => "Frustration and Anger",
      "Manifestor" => "Anger",
      "Projector" => "Bitterness",
      "Reflector" => "Disappointment"
    }.freeze

    attr_reader :birth, :personality, :design, :body_graph

    def initialize(birth_data, ephemeris: Ephemeris.new)
      @birth = birth_data
      birth_jd = birth_data.julian_day
      @personality = ActivationSet.new(birth_jd, ephemeris)
      @design = ActivationSet.new(DesignMoment.julian_day(birth_jd, ephemeris), ephemeris)
      @body_graph = BodyGraph.new(personality.gate_numbers + design.gate_numbers)
    end

    def type
      return "Reflector" if body_graph.defined_centers.empty?

      if body_graph.defined_centers.include?("Sacral")
        body_graph.motor_connected_to_throat? ? "Manifesting Generator" : "Generator"
      elsif body_graph.motor_connected_to_throat?
        "Manifestor"
      else
        "Projector"
      end
    end

    def strategy
      STRATEGIES.fetch(type)
    end

    def not_self_theme
      NOT_SELF_THEMES.fetch(type)
    end

    # Highest-priority defined center present.
    def authority
      return "Emotional (Solar Plexus)" if center_defined?("SolarPlexus")
      return "Sacral" if center_defined?("Sacral")
      return "Splenic" if center_defined?("Spleen")
      return "Ego / Heart" if center_defined?("Heart")
      return "Self-Projected (G)" if center_defined?("G")
      return "Lunar" if type == "Reflector"

      "Mental / Environmental (no inner authority)"
    end

    def profile
      "#{personality.sun_gate.line}/#{design.sun_gate.line}"
    end

    private

    def center_defined?(name)
      body_graph.defined_centers.include?(name)
    end
  end
end

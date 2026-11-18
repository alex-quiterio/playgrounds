# frozen_string_literal: true

module HumanDesign
  # The 13 bodies used in HD (Sun..Pluto + the lunar Nodes), in chart order.
  class Planet
    BODY_BY_NAME = {
      "Sun"       => :sun,
      "Earth"     => :earth,                # Sun + 180°
      "Moon"      => :moon,
      "NorthNode" => :north_node,
      "SouthNode" => :south_node,           # NorthNode + 180°
      "Mercury"   => :mercury,
      "Venus"     => :venus,
      "Mars"      => :mars,
      "Jupiter"   => :jupiter,
      "Saturn"    => :saturn,
      "Uranus"    => :uranus,
      "Neptune"   => :neptune,
      "Pluto"     => :pluto
    }.freeze

    ALL = BODY_BY_NAME.keys.freeze

    attr_reader :name

    def initialize(name)
      @name = name
    end

    def body
      BODY_BY_NAME.fetch(name)
    end

    def gate_at(jd, ephemeris)
      Gate.at(ephemeris.longitude(jd, body))
    end
  end
end

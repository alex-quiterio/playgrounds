# frozen_string_literal: true

module HumanDesign
  # The only class that touches the Swiss Ephemeris (the swe4r gem). It answers
  # one question: the ecliptic longitude (0..360) of a body at a Julian Day.
  # Anything with the same #longitude(jd, body) can stand in for it.
  class Ephemeris
    class MissingGemError < StandardError; end

    SWISS_BODIES = {
      sun: :SE_SUN, moon: :SE_MOON, mercury: :SE_MERCURY, venus: :SE_VENUS,
      mars: :SE_MARS, jupiter: :SE_JUPITER, saturn: :SE_SATURN,
      uranus: :SE_URANUS, neptune: :SE_NEPTUNE, pluto: :SE_PLUTO,
      north_node: :SE_TRUE_NODE
    }.freeze

    BODIES = (SWISS_BODIES.keys + %i[earth south_node]).freeze

    def initialize
      require "swe4r"
    rescue LoadError
      raise MissingGemError, "The 'swe4r' gem is not installed. Install it with: gem install swe4r"
    end

    def longitude(jd, body)
      case body
      when :earth then (longitude(jd, :sun) + 180.0) % 360.0
      when :south_node then (longitude(jd, :north_node) + 180.0) % 360.0
      else Swe4r.swe_calc_ut(jd, Swe4r.const_get(SWISS_BODIES.fetch(body)), flags)[0] % 360.0
      end
    end

    private

    def flags
      Swe4r::SEFLG_SWIEPH | Swe4r::SEFLG_SPEED
    end
  end
end

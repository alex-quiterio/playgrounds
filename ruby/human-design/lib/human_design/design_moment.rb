# frozen_string_literal: true

module HumanDesign
  # Finds the Design Julian Day: the moment the Sun was exactly 88° of arc
  # before its birth longitude. Solved by bisection (~88 days earlier).
  class DesignMoment
    ARC_DEGREES = 88.0
    SEARCH_WINDOW = (95.0..80.0)
    ITERATIONS = 40

    def self.julian_day(birth_jd, ephemeris)
      new(birth_jd, ephemeris).julian_day
    end

    def initialize(birth_jd, ephemeris)
      @birth_jd = birth_jd
      @ephemeris = ephemeris
      @target = (ephemeris.longitude(birth_jd, :sun) - ARC_DEGREES) % 360.0
    end

    def julian_day
      lo = @birth_jd - SEARCH_WINDOW.begin
      hi = @birth_jd - SEARCH_WINDOW.end
      ITERATIONS.times do
        mid = (lo + hi) / 2.0
        diff = signed_difference(@ephemeris.longitude(mid, :sun))
        diff.positive? ? hi = mid : lo = mid
      end
      (lo + hi) / 2.0
    end

    private

    def signed_difference(longitude)
      ((longitude - @target + 180.0) % 360.0) - 180.0
    end
  end
end

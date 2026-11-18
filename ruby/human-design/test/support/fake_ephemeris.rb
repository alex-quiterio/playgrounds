# A stand-in for HumanDesign::Ephemeris so specs run without the swe4r gem.
#
# The Sun moves linearly (about 0.9856 degrees a day), which is all
# DesignMoment needs to find the "88 degrees earlier" moment. Every other body
# sits at a fixed longitude, whatever the date.
class FakeEphemeris
  SUN_RATE = 0.9856

  def initialize(birth_jd:, sun_at_birth:, others: {})
    @birth_jd = birth_jd
    @sun_at_birth = sun_at_birth
    @others = others
  end

  def longitude(jd, body)
    case body
    when :sun then (@sun_at_birth + SUN_RATE * (jd - @birth_jd)) % 360.0
    when :earth then (longitude(jd, :sun) + 180.0) % 360.0
    when :south_node then (longitude(jd, :north_node) + 180.0) % 360.0
    else @others.fetch(body)
    end
  end

  # Longitude in the middle of a given gate and line of the wheel.
  def self.longitude_of(gate_number, line = 1)
    index = HumanDesign::Gate::WHEEL.index(gate_number)
    HumanDesign::Gate::START_DEG + index * HumanDesign::Gate::SIZE +
      (line - 0.5) * HumanDesign::Gate::LINE_SIZE
  end
end

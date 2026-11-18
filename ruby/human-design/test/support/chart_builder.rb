# Builds a Chart with the fake ephemeris, so a spec can say which gates it wants.
#
# The Sun sits at 2 degrees, which makes the Sun/Earth gates 25.5 / 46.5 and the
# Design Sun/Earth gates 58.1 / 52.1. None of those four completes a channel on
# its own or with the gates the specs use, so the chart is shaped only by the
# `gates` a spec passes in. Every unused slot (and the North Node, hence the
# South Node) sits on gate 25, which is harmless for the same reason.
module ChartBuilder
  SUN_AT_BIRTH = 2.0
  FILLER_GATE = 25
  SLOTS = %i[moon mercury venus mars jupiter saturn uranus neptune pluto].freeze

  def chart_with(*gates)
    birth = HumanDesign::BirthData.new(year: 1990, month: 3, day: 14, hour: 9, min: 30, utc_offset: 1)
    others = { north_node: FakeEphemeris.longitude_of(FILLER_GATE) }
    SLOTS.each_with_index do |body, index|
      others[body] = FakeEphemeris.longitude_of(gates.fetch(index, FILLER_GATE))
    end
    ephemeris = FakeEphemeris.new(birth_jd: birth.julian_day, sun_at_birth: SUN_AT_BIRTH, others: others)
    HumanDesign::Chart.new(birth, ephemeris: ephemeris)
  end
end

Minitest::Spec.include ChartBuilder

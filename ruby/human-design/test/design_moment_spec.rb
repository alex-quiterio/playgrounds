require 'test_helper'

describe HumanDesign::DesignMoment do
  let(:birth_jd) { 2_448_000.5 }
  let(:ephemeris) { FakeEphemeris.new(birth_jd: birth_jd, sun_at_birth: 123.0) }

  it 'finds the moment the Sun was 88 degrees of arc earlier' do
    design_jd = HumanDesign::DesignMoment.julian_day(birth_jd, ephemeris)
    assert_in_delta 123.0 - 88.0, ephemeris.longitude(design_jd, :sun), 1e-6
  end

  it 'is about 88 days before birth' do
    design_jd = HumanDesign::DesignMoment.julian_day(birth_jd, ephemeris)
    assert_in_delta 88.0 / FakeEphemeris::SUN_RATE, birth_jd - design_jd, 1e-6
  end

  it 'works when the arc crosses 0 degrees' do
    ephemeris = FakeEphemeris.new(birth_jd: birth_jd, sun_at_birth: 40.0)
    design_jd = HumanDesign::DesignMoment.julian_day(birth_jd, ephemeris)
    assert_in_delta (40.0 - 88.0) % 360.0, ephemeris.longitude(design_jd, :sun), 1e-6
  end
end

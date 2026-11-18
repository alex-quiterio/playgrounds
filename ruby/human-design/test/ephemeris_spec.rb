require 'test_helper'

# Integration specs against the real Swiss Ephemeris. They skip themselves when
# the swe4r gem is not installed (gem install swe4r).
describe HumanDesign::Ephemeris do
  before do
    begin
      require 'swe4r'
    rescue LoadError
      skip 'swe4r gem not installed'
    end
  end

  let(:ephemeris) { HumanDesign::Ephemeris.new }
  let(:j2000) { 2_451_545.0 }

  it 'puts the Sun near 280.4 degrees at J2000.0' do
    assert_in_delta 280.4, ephemeris.longitude(j2000, :sun), 0.2
  end

  it 'reads the Earth opposite the Sun' do
    assert_in_delta (ephemeris.longitude(j2000, :sun) + 180.0) % 360.0,
                    ephemeris.longitude(j2000, :earth), 1e-9
  end

  it 'reads the South Node opposite the North Node' do
    assert_in_delta (ephemeris.longitude(j2000, :north_node) + 180.0) % 360.0,
                    ephemeris.longitude(j2000, :south_node), 1e-9
  end

  it 'returns longitudes between 0 and 360 for every body' do
    HumanDesign::Ephemeris::BODIES.each do |body|
      longitude = ephemeris.longitude(j2000, body)
      assert_operator longitude, :>=, 0.0
      assert_operator longitude, :<, 360.0
    end
  end

  it 'builds a full chart whose design is about 88 days before birth' do
    birth = HumanDesign::BirthData.new(year: 1990, month: 3, day: 14, hour: 9, min: 30, utc_offset: 1)
    chart = HumanDesign::Chart.new(birth, ephemeris: ephemeris)
    design_jd = HumanDesign::DesignMoment.julian_day(birth.julian_day, ephemeris)
    assert_in_delta 88.0, birth.julian_day - design_jd, 3.0
    assert_match(/\A[1-6]\/[1-6]\z/, chart.profile)
    assert_includes HumanDesign::Chart::STRATEGIES.keys, chart.type
  end

  it 'reports a missing gem clearly' do
    original = HumanDesign::Ephemeris.instance_method(:initialize)
    HumanDesign::Ephemeris.send(:define_method, :initialize) do
      raise HumanDesign::Ephemeris::MissingGemError, "The 'swe4r' gem is not installed."
    end
    error = assert_raises(HumanDesign::Ephemeris::MissingGemError) { HumanDesign::Ephemeris.new }
    assert_match(/swe4r/, error.message)
  ensure
    HumanDesign::Ephemeris.send(:define_method, :initialize, original)
  end
end

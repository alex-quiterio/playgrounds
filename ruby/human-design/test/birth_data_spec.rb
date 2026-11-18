require 'test_helper'

describe HumanDesign::BirthData do
  def birth(**overrides)
    HumanDesign::BirthData.new(
      **{ year: 1990, month: 3, day: 14, hour: 9, min: 30, utc_offset: 1 }.merge(overrides)
    )
  end

  it 'computes the Julian Day of J2000.0' do
    j2000 = birth(year: 2000, month: 1, day: 1, hour: 12, min: 0, utc_offset: 0)
    assert_in_delta 2_451_545.0, j2000.julian_day, 1e-9
  end

  it 'applies the UTC offset' do
    utc = birth(year: 2000, month: 1, day: 1, hour: 12, min: 0, utc_offset: 0)
    cet = birth(year: 2000, month: 1, day: 1, hour: 13, min: 0, utc_offset: 1)
    assert_in_delta utc.julian_day, cet.julian_day, 1e-9
  end

  it 'handles offsets that cross midnight' do
    late = birth(year: 2000, month: 1, day: 1, hour: 23, min: 0, utc_offset: -5)
    next_day = birth(year: 2000, month: 1, day: 2, hour: 4, min: 0, utc_offset: 0)
    assert_in_delta next_day.julian_day, late.julian_day, 1e-9
  end

  it 'counts minutes' do
    assert_in_delta 0.5 / 24.0, birth(min: 30).julian_day - birth(min: 0).julian_day, 1e-9
  end

  it 'prints day/month/year, time and offset' do
    assert_equal '14/3/1990 09:30 (UTC+1)', birth.to_s
    assert_equal '1/12/2001 00:05 (UTC-5)',
                 birth(year: 2001, month: 12, day: 1, hour: 0, min: 5, utc_offset: -5).to_s
  end

  it 'builds itself from prompts' do
    data = nil
    with_input("1990\n3\n14\n9\n30\n1\n") do
      capture_io { data = HumanDesign::BirthData.prompt }
    end
    assert_equal '14/3/1990 09:30 (UTC+1)', data.to_s
  end
end

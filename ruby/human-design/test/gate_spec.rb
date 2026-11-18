require 'test_helper'

describe HumanDesign::Gate do
  Gate = HumanDesign::Gate

  it 'places each of the 64 gates on the wheel exactly once' do
    assert_equal (1..64).to_a, Gate::WHEEL.sort
  end

  it 'starts the wheel with gate 41 at 2 degrees Aquarius' do
    assert_equal '41.1', Gate.at(302.0).to_s
  end

  it 'wraps around the zodiac just before the start' do
    assert_equal '60.6', Gate.at(301.999).to_s
    assert_equal '60.6', Gate.at(-0.001 + 302.0).to_s
  end

  it 'moves to the next gate every 5.625 degrees' do
    assert_equal '19.1', Gate.at(302.0 + Gate::SIZE).to_s
    assert_equal '41.6', Gate.at(302.0 + Gate::SIZE - 0.001).to_s
  end

  it 'moves to the next line every 0.9375 degrees' do
    assert_equal '41.2', Gate.at(302.0 + Gate::LINE_SIZE).to_s
  end

  it 'accepts longitudes beyond 360' do
    assert_equal Gate.at(2.0).to_s, Gate.at(362.0).to_s
  end

  it 'knows the center it belongs to' do
    assert_equal 'Root', Gate.new(41, 1).center
    assert_equal 'Throat', Gate.new(20, 3).center
  end

  it 'finds the same gate and line the fake ephemeris aims for' do
    [[25, 1], [41, 6], [60, 3], [12, 4]].each do |number, line|
      gate = Gate.at(FakeEphemeris.longitude_of(number, line))
      assert_equal [number, line], [gate.number, gate.line]
    end
  end
end

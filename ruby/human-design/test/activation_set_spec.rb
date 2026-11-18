require 'test_helper'

describe HumanDesign::ActivationSet do
  let(:ephemeris) do
    others = HumanDesign::Ephemeris::BODIES.to_h { |body| [body, FakeEphemeris.longitude_of(25, 3)] }
    FakeEphemeris.new(birth_jd: 100.0, sun_at_birth: FakeEphemeris.longitude_of(12, 2), others: others)
  end
  let(:set) { HumanDesign::ActivationSet.new(100.0, ephemeris) }

  it 'has a gate for each of the 13 planets' do
    HumanDesign::Planet::ALL.each { |name| assert_kind_of HumanDesign::Gate, set.gate_for(name) }
    assert_equal 13, HumanDesign::Planet::ALL.size
  end

  it 'reads the Sun and Earth as opposite points' do
    assert_equal '12.2', set.sun_gate.to_s
    assert_equal '12.2', set.gate_for('Sun').to_s
    assert_equal 12, set.sun_gate.number
    assert_equal HumanDesign::Gate::WHEEL[(HumanDesign::Gate::WHEEL.index(12) + 32) % 64],
                 set.gate_for('Earth').number
  end

  it 'lists each gate number once' do
    assert_equal set.gate_numbers.uniq, set.gate_numbers
  end

  it 'yields every planet with its gate' do
    names = []
    set.each_gate { |name, gate| names << name; assert_kind_of HumanDesign::Gate, gate }
    assert_equal HumanDesign::Planet::ALL, names
  end

  it 'raises for an unknown planet' do
    assert_raises(KeyError) { set.gate_for('Chiron') }
  end
end

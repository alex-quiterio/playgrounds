require 'test_helper'

describe HumanDesign::Center do
  Center = HumanDesign::Center

  it 'has nine centers' do
    assert_equal 9, Center::ALL.size
  end

  it 'gives every gate to exactly one center' do
    all_gates = Center::GATES_BY_NAME.values.flatten
    assert_equal (1..64).to_a, all_gates.sort
  end

  it 'finds the center containing a gate' do
    assert_equal 'Sacral', Center.containing(34)
    assert_equal 'SolarPlexus', Center.containing(6)
    assert_equal 'Head', Center.containing(61)
  end

  it 'returns nil for a gate that does not exist' do
    assert_nil Center.containing(99)
  end

  it 'lists the four motors' do
    assert_equal %w[Heart Root Sacral SolarPlexus], Center::MOTORS.sort
  end
end

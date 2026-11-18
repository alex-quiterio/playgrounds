require 'test_helper'

describe HumanDesign::Chart do
  describe 'type, strategy and not-self theme' do
    it 'is a Reflector with no defined centers' do
      chart = chart_with
      assert_empty chart.body_graph.defined_centers
      assert_equal 'Reflector', chart.type
      assert_equal 'Wait a lunar cycle before deciding', chart.strategy
      assert_equal 'Disappointment', chart.not_self_theme
    end

    it 'is a Generator with a Sacral and no motor to the throat' do
      chart = chart_with(5, 15)               # Sacral - G
      assert_equal 'Generator', chart.type
      assert_equal 'To respond', chart.strategy
      assert_equal 'Frustration', chart.not_self_theme
    end

    it 'is a Manifesting Generator when the Sacral reaches the throat' do
      chart = chart_with(34, 20)              # Sacral - Throat
      assert_equal 'Manifesting Generator', chart.type
      assert_equal 'To respond, then inform', chart.strategy
      assert_equal 'Frustration and Anger', chart.not_self_theme
    end

    it 'is a Manifestor when a motor reaches the throat without the Sacral' do
      chart = chart_with(21, 45)              # Heart - Throat
      assert_equal 'Manifestor', chart.type
      assert_equal 'To inform before you act', chart.strategy
      assert_equal 'Anger', chart.not_self_theme
    end

    it 'is a Projector with a definition but no Sacral or motor to the throat' do
      chart = chart_with(1, 8)                # G - Throat
      assert_equal 'Projector', chart.type
      assert_equal 'Wait for the invitation', chart.strategy
      assert_equal 'Bitterness', chart.not_self_theme
    end
  end

  describe 'authority' do
    it 'is Emotional when the Solar Plexus is defined, even with a Sacral' do
      chart = chart_with(6, 59)               # Solar Plexus - Sacral
      assert_equal 'Emotional (Solar Plexus)', chart.authority
    end

    it 'is Sacral for a defined Sacral' do
      assert_equal 'Sacral', chart_with(5, 15).authority
    end

    it 'is Ego / Heart for a defined Heart without Sacral, Solar Plexus or Spleen' do
      assert_equal 'Ego / Heart', chart_with(21, 45).authority
    end

    it 'is Self-Projected for a defined G with a defined Throat only' do
      assert_equal 'Self-Projected (G)', chart_with(1, 8).authority
    end

    it 'is Lunar for a Reflector' do
      assert_equal 'Lunar', chart_with.authority
    end
  end

  describe 'profile' do
    it 'combines the lines of the conscious and design Sun' do
      # Sun at 2 degrees is 25.5; 88 degrees earlier (274) is 58.1
      chart = chart_with
      assert_equal '25.5', chart.personality.sun_gate.to_s
      assert_equal '58.1', chart.design.sun_gate.to_s
      assert_equal '5/1', chart.profile
    end
  end

  describe 'definition' do
    it 'is split when channels do not touch' do
      chart = chart_with(5, 15, 21, 45)
      assert_equal 'Split Definition', chart.body_graph.definition_type
    end
  end

  it 'collects activations for both charts' do
    chart = chart_with(5, 15)
    assert_includes chart.personality.gate_numbers, 5
    assert_includes chart.design.gate_numbers, 15
    assert_equal 13, HumanDesign::Planet::ALL.count { |name| chart.personality.gate_for(name) }
  end
end

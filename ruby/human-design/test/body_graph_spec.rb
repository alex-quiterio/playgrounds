require 'test_helper'

describe HumanDesign::BodyGraph do
  def graph(*gates)
    HumanDesign::BodyGraph.new(gates)
  end

  it 'has no definition without a complete channel' do
    bg = graph(5, 20, 1)
    assert_empty bg.active_channels
    assert_empty bg.defined_centers
    assert_equal 'No Definition', bg.definition_type
    assert_equal 9, bg.undefined_centers.size
  end

  it 'defines both centers of a complete channel' do
    bg = graph(5, 15)
    assert_equal %w[G Sacral], bg.defined_centers.sort
    assert_equal 7, bg.undefined_centers.size
  end

  it 'ignores duplicate gates' do
    assert_equal graph(5, 15).active_channels.size, graph(5, 15, 5, 15).active_channels.size
  end

  it 'reports gates that are not part of a channel as hanging' do
    bg = graph(5, 15, 34, 61)
    assert_equal [34, 61], bg.hanging_gates.sort
    assert_equal({ 'Sacral' => [34], 'Head' => [61] }, bg.hanging_gates_by_center)
  end

  it 'connects centers joined through a chain of channels' do
    bg = graph(5, 15, 10, 20)
    assert bg.connected?('Sacral', 'Throat')
    refute bg.connected?('Sacral', 'Heart')
    refute bg.connected?('Head', 'Sacral')
  end

  it 'counts separate components as the definition type' do
    assert_equal 'Single Definition', graph(5, 15).definition_type
    assert_equal 'Split Definition', graph(5, 15, 21, 45).definition_type
    assert_equal 'Triple Split Definition', graph(5, 15, 21, 45, 47, 64).definition_type
  end

  it 'detects a motor connected to the throat' do
    assert graph(21, 45).motor_connected_to_throat?        # Heart - Throat
    assert graph(20, 34).motor_connected_to_throat?        # Sacral - Throat
    refute graph(1, 8).motor_connected_to_throat?          # G - Throat, no motor
    refute graph(5, 15).motor_connected_to_throat?         # no throat at all
  end
end

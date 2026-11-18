require 'test_helper'

describe HumanDesign::Channel do
  Channel = HumanDesign::Channel

  it 'has the 36 channels' do
    assert_equal 36, Channel.all.size
  end

  it 'connects, for every channel, the centers its two gates belong to' do
    Channel.all.each do |channel|
      expected = channel.gates.map { |gate| HumanDesign::Center.containing(gate) }
      assert_equal expected.sort, channel.centers.sort, "channel #{channel}"
    end
  end

  it 'is active only when both gates are active' do
    channel = Channel.new([20, 34], %w[Throat Sacral])
    assert channel.active?([20, 34, 1])
    refute channel.active?([20, 1])
    refute channel.active?([])
  end

  it 'knows which gates it includes' do
    channel = Channel.new([20, 34], %w[Throat Sacral])
    assert channel.includes_gate?(34)
    refute channel.includes_gate?(10)
  end

  it 'prints its gates and centers' do
    assert_equal '20-34  (Throat <-> Sacral)', Channel.new([20, 34], %w[Throat Sacral]).to_s
  end
end

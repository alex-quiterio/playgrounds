require 'test_helper'

describe HumanDesign::Ansi do
  Ansi = HumanDesign::Ansi

  it 'leaves text plain when NO_COLOR is set, even if colour is forced' do
    with_env('NO_COLOR' => '1', 'FORCE_COLOR' => '1') do
      refute Ansi.enabled?
      assert_equal 'hi', Ansi.paint('hi', Ansi.fg(1), '1')
    end
  end

  it 'leaves text plain when stdout is not a terminal' do
    with_env('NO_COLOR' => nil, 'FORCE_COLOR' => nil) do
      refute Ansi.enabled?
    end
  end

  it 'wraps text in escape codes when colour is forced' do
    with_env('NO_COLOR' => nil, 'FORCE_COLOR' => '1') do
      assert Ansi.enabled?
      assert_equal "\e[38;5;141;1mhi\e[0m", Ansi.paint('hi', Ansi.fg(141), '1')
      assert_equal "\e[48;5;16mhi\e[0m", Ansi.paint('hi', Ansi.bg(16))
    end
  end

  it 'measures text without escape codes' do
    assert_equal 'hi', Ansi.visible("\e[1mhi\e[0m")
  end

  it 'pads by visible width' do
    colored = "\e[1mhi\e[0m"
    assert_equal "#{colored}   ", Ansi.pad(colored, 5)
    assert_equal 'toolong', Ansi.pad('toolong', 3)
  end

  it 'centers by visible width, leaving the odd space on the right' do
    assert_equal ' hi  ', Ansi.center('hi', 5)
    assert_equal ' ab ', Ansi.center("\e[1mab\e[0m", 4).sub("\e[1m", '').sub("\e[0m", '')
  end
end

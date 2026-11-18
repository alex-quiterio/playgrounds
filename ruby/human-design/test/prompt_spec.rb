require 'test_helper'

describe HumanDesign::Prompt do
  Prompt = HumanDesign::Prompt

  def ask_with(input)
    result = nil
    out, = capture_io { with_input(input) { result = yield } }
    [result, out]
  end

  it 'returns the stripped answer' do
    result, out = ask_with("  hello \n") { Prompt.ask('Say') }
    assert_equal 'hello', result
    assert_includes out, 'Say: '
  end

  it 'returns nil at end of input' do
    result, = ask_with('') { Prompt.ask('Say') }
    assert_nil result
  end

  it 'asks again until an integer is inside the range' do
    result, out = ask_with("abc\n13\n7\n") { Prompt.integer('Month', 1..12) }
    assert_equal 7, result
    assert_equal 2, out.scan('Please enter a whole number in 1..12.').size
  end

  it 'accepts negative integers when the range allows them' do
    result, = ask_with("-3\n") { Prompt.integer('Offset', -12..14) }
    assert_equal(-3, result)
  end

  it 'parses floats, including negative and whole ones' do
    assert_equal 5.5, ask_with("5.5\n") { Prompt.float('Offset') }.first
    assert_equal(-5.0, ask_with("-5\n") { Prompt.float('Offset') }.first)
  end

  it 'asks again for a bad float' do
    result, out = ask_with("one\n2\n") { Prompt.float('Offset') }
    assert_equal 2.0, result
    assert_includes out, 'Please enter a number.'
  end

  it 'asks again for empty text' do
    result, out = ask_with("\n   \nAlex\n") { Prompt.text('Name') }
    assert_equal 'Alex', result
    assert_equal 2, out.scan('Please enter a value.').size
  end
end

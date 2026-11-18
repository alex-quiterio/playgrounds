require 'test_helper'

describe HumanDesign::Numerology do
  Birth = Struct.new(:day, :month, :year)

  def numerology(name = 'Abe', day: 14, month: 3, year: 1990)
    HumanDesign::Numerology.new(name, Birth.new(day, month, year))
  end

  it 'reduces day, month and year separately for the life path' do
    # 14 -> 5, 3, 1990 -> 19 -> 10 -> 1; 5 + 3 + 1 = 9
    assert_equal 9, numerology.life_path_number
  end

  it 'keeps master numbers in the life path' do
    assert_equal 11, numerology(day: 1, month: 1, year: 1998).life_path_number
    assert_equal 22, numerology(day: 2, month: 11, year: 1998).life_path_number
    assert_equal 33, numerology(day: 2, month: 9, year: 1993).life_path_number
  end

  it 'reduces the birthday number but keeps masters' do
    assert_equal 5, numerology(day: 14).birthday_number
    assert_equal 11, numerology(day: 29).birthday_number
    assert_equal 22, numerology(day: 22).birthday_number
  end

  it 'adds all letters for expression, vowels for soul urge, consonants for personality' do
    # A=1 B=2 E=5
    assert_equal 8, numerology('Abe').expression_number
    assert_equal 6, numerology('Abe').soul_urge_number
    assert_equal 2, numerology('Abe').personality_number
  end

  it 'ignores case, spaces and non-letters' do
    assert_equal numerology('Abe').expression_number, numerology('  a-b e! ').expression_number
  end

  it 'counts accented letters as their plain letter' do
    assert_equal numerology('Jose Quiterio').expression_number, numerology('José Quitério').expression_number
    assert_equal numerology('Jose Quiterio').soul_urge_number, numerology('José Quitério').soul_urge_number
    assert_equal numerology('Jose Quiterio').personality_number, numerology('José Quitério').personality_number
  end

  it 'handles accents written as a letter plus a combining mark' do
    decomposed = "Jose\u0301" # e + combining acute
    assert_equal numerology('Jose').expression_number, numerology(decomposed).expression_number
  end

  it 'handles other diacritics' do
    assert_equal numerology('Joao Conceicao').expression_number, numerology('João Conceição').expression_number
  end

  it 'still ignores letters with no ASCII base' do
    assert_equal numerology('Abe').expression_number, numerology('Abe 名前').expression_number
  end
end

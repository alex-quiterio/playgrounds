# frozen_string_literal: true

module HumanDesign
  # Pythagorean numerology reading, derived from a full name and BirthData.
  # Only ASCII letters A-Z contribute to the letter-based numbers.
  class Numerology
    LETTER_VALUES = {
      "A" => 1, "B" => 2, "C" => 3, "D" => 4, "E" => 5, "F" => 6, "G" => 7, "H" => 8, "I" => 9,
      "J" => 1, "K" => 2, "L" => 3, "M" => 4, "N" => 5, "O" => 6, "P" => 7, "Q" => 8, "R" => 9,
      "S" => 1, "T" => 2, "U" => 3, "V" => 4, "W" => 5, "X" => 6, "Y" => 7, "Z" => 8
    }.freeze

    VOWELS = %w[A E I O U].freeze
    MASTER_NUMBERS = [11, 22, 33].freeze

    attr_reader :full_name, :birth

    def initialize(full_name, birth)
      @full_name = full_name
      @birth = birth
    end

    # Reduce day, month, and year separately, then sum and reduce again.
    def life_path_number
      reduce(reduce(birth.day) + reduce(birth.month) + reduce(birth.year))
    end

    def birthday_number
      reduce(birth.day)
    end

    def expression_number
      reduce(letter_values(letters).sum)
    end

    def soul_urge_number
      reduce(letter_values(letters.select { |l| VOWELS.include?(l) }).sum)
    end

    def personality_number
      reduce(letter_values(letters.reject { |l| VOWELS.include?(l) }).sum)
    end

    private

    def letters
      full_name.upcase.scan(/[A-Z]/)
    end

    def letter_values(chars)
      chars.map { |c| LETTER_VALUES.fetch(c) }
    end

    def reduce(number)
      loop do
        return number if number <= 9 || MASTER_NUMBERS.include?(number)
        number = number.digits.sum
      end
    end
  end
end

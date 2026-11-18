# frozen_string_literal: true

module HumanDesign
  # One of the 64 I Ching gates plus a line number (1..6), derived from an
  # ecliptic longitude.
  class Gate
    # The 64 gates in zodiacal order around the 360° ecliptic. HD places
    # Gate 41 at the start (2° Aquarius region); each gate spans 5.625°.
    WHEEL = [
      41, 19, 13, 49, 30, 55, 37, 63, 22, 36, 25, 17, 21, 51, 42, 3,
      27, 24, 2, 23, 8, 20, 16, 35, 45, 12, 15, 52, 39, 53, 62, 56,
      31, 33, 7, 4, 29, 59, 40, 64, 47, 6, 46, 18, 48, 57, 32, 50,
      28, 44, 1, 43, 14, 34, 9, 5, 26, 11, 10, 58, 38, 54, 61, 60
    ].freeze

    # The wheel starts at this absolute ecliptic longitude (start of Gate 41).
    # 302° = 2° Aquarius. Standard offset used by mainstream HD software.
    START_DEG = 302.0
    SIZE = 360.0 / 64.0        # 5.625°
    LINE_SIZE = SIZE / 6.0     # each gate has 6 lines

    attr_reader :number, :line

    def self.at(longitude)
      offset = (longitude - START_DEG) % 360.0
      idx = (offset / SIZE).floor
      within = offset - idx * SIZE
      new(WHEEL[idx], (within / LINE_SIZE).floor + 1)
    end

    def initialize(number, line)
      @number = number
      @line = line
    end

    def center
      Center.containing(number)
    end

    def to_s
      "#{number}.#{line}"
    end
  end
end

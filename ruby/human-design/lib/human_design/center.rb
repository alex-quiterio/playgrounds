# frozen_string_literal: true

module HumanDesign
  # One of the 9 centers in the BodyGraph, and which gates belong to it.
  class Center
    GATES_BY_NAME = {
      "Head"        => [64, 61, 63],
      "Ajna"        => [47, 24, 4, 17, 43, 11],
      "Throat"      => [62, 23, 56, 35, 12, 45, 33, 8, 31, 20, 16],
      "G"           => [1, 13, 25, 46, 2, 15, 10, 7],
      "Heart"       => [21, 40, 26, 51],                 # Ego / Will
      "Spleen"      => [48, 57, 44, 50, 32, 28, 18],
      "SolarPlexus" => [6, 37, 22, 36, 30, 55, 49],       # Emotional
      "Sacral"      => [34, 5, 14, 29, 59, 9, 3, 42, 27],
      "Root"        => [58, 38, 54, 53, 60, 52, 19, 39, 41]
    }.freeze

    ALL = GATES_BY_NAME.keys.freeze
    MOTORS = %w[Sacral Heart SolarPlexus Root].freeze

    def self.containing(gate_number)
      GATES_BY_NAME.find { |_name, gates| gates.include?(gate_number) }&.first
    end
  end
end

# frozen_string_literal: true

module HumanDesign
  # One of the 36 channels connecting two gates (and thus two centers).
  class Channel
    CENTERS_BY_GATES = {
      [1, 8]   => %w[G Throat],
      [2, 14]  => %w[G Sacral],
      [3, 60]  => %w[Sacral Root],
      [4, 63]  => %w[Ajna Head],
      [5, 15]  => %w[Sacral G],
      [6, 59]  => %w[SolarPlexus Sacral],
      [7, 31]  => %w[G Throat],
      [9, 52]  => %w[Sacral Root],
      [10, 20] => %w[G Throat],
      [10, 34] => %w[G Sacral],
      [10, 57] => %w[G Spleen],
      [11, 56] => %w[Ajna Throat],
      [12, 22] => %w[Throat SolarPlexus],
      [13, 33] => %w[G Throat],
      [16, 48] => %w[Throat Spleen],
      [17, 62] => %w[Ajna Throat],
      [18, 58] => %w[Spleen Root],
      [19, 49] => %w[Root SolarPlexus],
      [20, 34] => %w[Throat Sacral],
      [20, 57] => %w[Throat Spleen],
      [21, 45] => %w[Heart Throat],
      [23, 43] => %w[Throat Ajna],
      [24, 61] => %w[Ajna Head],
      [25, 51] => %w[G Heart],
      [26, 44] => %w[Heart Spleen],
      [27, 50] => %w[Sacral Spleen],
      [28, 38] => %w[Spleen Root],
      [29, 46] => %w[Sacral G],
      [30, 41] => %w[SolarPlexus Root],
      [32, 54] => %w[Spleen Root],
      [34, 57] => %w[Sacral Spleen],
      [35, 36] => %w[Throat SolarPlexus],
      [37, 40] => %w[SolarPlexus Heart],
      [39, 55] => %w[Root SolarPlexus],
      [42, 53] => %w[Sacral Root],
      [47, 64] => %w[Ajna Head]
    }.freeze

    attr_reader :gates, :centers

    def self.all
      @all ||= CENTERS_BY_GATES.map { |gates, centers| new(gates, centers) }
    end

    def initialize(gates, centers)
      @gates = gates
      @centers = centers
    end

    def includes_gate?(gate_number)
      gates.include?(gate_number)
    end

    def active?(active_gate_numbers)
      gates.all? { |g| active_gate_numbers.include?(g) }
    end

    def to_s
      "#{gates.min}-#{gates.max}  (#{centers.join(' <-> ')})"
    end
  end
end

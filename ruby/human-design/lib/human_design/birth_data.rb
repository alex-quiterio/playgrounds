# frozen_string_literal: true

require "date"

module HumanDesign
  # Local civil birth date/time plus its UTC offset.
  class BirthData
    attr_reader :year, :month, :day, :hour, :min, :utc_offset

    def self.prompt
      puts "Enter birth data (local clock date/time):"
      data = new(
        year: Prompt.integer("Birth year (e.g. 1990)", 1800..2100),
        month: Prompt.integer("Birth month (1-12)", 1..12),
        day: Prompt.integer("Birth day (1-31)", 1..31),
        hour: Prompt.integer("Birth hour, 24h local clock (0-23)", 0..23),
        min: Prompt.integer("Birth minute (0-59)", 0..59),
        utc_offset: Prompt.float("UTC offset in hours (e.g. 1 for UTC+1, -5 for UTC-5)")
      )
      puts
      data
    end

    def initialize(year:, month:, day:, hour:, min:, utc_offset:)
      @year = year
      @month = month
      @day = day
      @hour = hour
      @min = min
      @utc_offset = utc_offset
    end

    # Julian Day (UT). Date#jd is the day number at noon, so subtract 0.5 to
    # get midnight, then add the UT time of day.
    def julian_day
      ut_hour = hour + min / 60.0 - utc_offset
      Date.new(year, month, day).jd - 0.5 + ut_hour / 24.0
    end

    def to_s
      "#{day}/#{month}/#{year} " \
        "#{format('%02d:%02d', hour, min)} " \
        "(UTC#{format('%+d', utc_offset)})"
    end
  end
end

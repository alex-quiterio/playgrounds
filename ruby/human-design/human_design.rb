#!/usr/bin/env ruby
# frozen_string_literal: true

# Usage:
#   gem install swe4r
#   ruby human_design.rb              # prompts for birth date, time and UTC offset
#   ruby human_design.rb --with-num   # also prompts for a name, adds numerology

require_relative "lib/human_design"

begin
  ephemeris = HumanDesign::Ephemeris.new
rescue HumanDesign::Ephemeris::MissingGemError => e
  abort e.message
end

birth = HumanDesign::BirthData.prompt
chart = HumanDesign::Chart.new(birth, ephemeris: ephemeris)

numerology = nil
if ARGV.include?("--with-num")
  name = HumanDesign::Prompt.text("Full name (for numerology)")
  numerology = HumanDesign::Numerology.new(name, birth)
  puts
end

HumanDesign::ChartReport.new(chart, numerology: numerology).render

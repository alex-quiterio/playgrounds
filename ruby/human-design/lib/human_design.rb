# frozen_string_literal: true

# Compute a Human Design chart (Type, Authority, Profile, defined Centers,
# active gates/channels) from birth data, plus a Pythagorean numerology reading.
#
# Human Design is derived from TWO charts:
#   1. Personality (conscious): the exact moment of birth.
#   2. Design (unconscious):    the moment the Sun was exactly 88 degrees of arc
#      BEFORE its birth position (~88 days before birth).
# The 13 planetary activations from each are mapped onto the 64 I Ching gates,
# then onto channels and the 9 centers.
module HumanDesign
end

%w[
  prompt ephemeris birth_data gate center channel planet activation_set
  design_moment body_graph chart numerology ansi chart_report
].each { |name| require_relative "human_design/#{name}" }

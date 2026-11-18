require 'minitest/autorun'
require 'stringio'
require 'human_design'
require 'support/fake_ephemeris'
require 'support/chart_builder'

module SpecHelpers
  # Sets ENV keys for the block, then restores them.
  def with_env(vars)
    saved = vars.keys.to_h { |key| [key, ENV[key]] }
    vars.each { |key, value| value.nil? ? ENV.delete(key) : ENV[key] = value }
    yield
  ensure
    saved.each { |key, value| value.nil? ? ENV.delete(key) : ENV[key] = value }
  end

  # Runs the block with Prompt reading from `text`.
  def with_input(text)
    HumanDesign::Prompt.input = StringIO.new(text)
    yield
  ensure
    HumanDesign::Prompt.input = nil
  end

  def strip_ansi(text)
    text.gsub(/\e\[[\d;]*m/, '')
  end
end

Minitest::Spec.include SpecHelpers

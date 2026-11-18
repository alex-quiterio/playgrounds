# frozen_string_literal: true

module HumanDesign
  # Interactive prompts shared by anything that needs user input. Reads from an
  # injectable IO (STDIN by default) rather than bare `gets`, which would read
  # files named in ARGV (e.g. "--with-num") instead of the terminal.
  module Prompt
    class << self
      attr_writer :input

      def input
        @input ||= STDIN
      end

      def ask(prompt)
        print "#{prompt}: "
        $stdout.flush
        input.gets&.strip
      end

      def integer(prompt, range)
        loop do
          value = ask(prompt)
          return value.to_i if value =~ /\A-?\d+\z/ && range.include?(value.to_i)

          puts "  Please enter a whole number in #{range}."
        end
      end

      def float(prompt)
        loop do
          value = ask(prompt)
          return value.to_f if value =~ /\A-?\d+(\.\d+)?\z/

          puts "  Please enter a number."
        end
      end

      def text(prompt)
        loop do
          value = ask(prompt)
          return value if value && !value.empty?

          puts "  Please enter a value."
        end
      end
    end
  end
end

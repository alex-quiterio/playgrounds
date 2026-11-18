# frozen_string_literal: true

module HumanDesign
  # Tiny ANSI helper. Colour is on for a TTY (or when FORCE_COLOR is set) and
  # always off when NO_COLOR is set. Uses 256-colour codes, so it works in any
  # modern terminal without truecolor support.
  module Ansi
    module_function

    def enabled?
      return false if ENV.key?("NO_COLOR")

      ENV.key?("FORCE_COLOR") || $stdout.tty?
    end

    def paint(text, *codes)
      return text.to_s unless enabled?

      "\e[#{codes.join(';')}m#{text}\e[0m"
    end

    def fg(number)
      "38;5;#{number}"
    end

    def bg(number)
      "48;5;#{number}"
    end

    def visible(text)
      text.to_s.gsub(/\e\[[\d;]*m/, "")
    end

    def pad(text, width)
      text.to_s + " " * [width - visible(text).length, 0].max
    end

    def center(text, width)
      extra = [width - visible(text).length, 0].max
      left = extra / 2
      " " * left + text.to_s + " " * (extra - left)
    end
  end
end

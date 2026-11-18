# frozen_string_literal: true

module HumanDesign
  # Formats a Chart as a colourful terminal report: type card, a BodyGraph
  # sketch, centers, channels, energy gauges, activations and numerology.
  class ChartReport
    WIDTH = 64
    INDENT = 6
    MID = 14 # column where the middle stack of centers starts

    ACCENT = 141
    FRAME = 60
    PERSONALITY = 255 # conscious: white (black in classic charts)
    DESIGN = 203      # unconscious: red
    BOTH = 177        # gate active in both charts

    TYPE_COLORS = {
      "Generator" => 215,
      "Manifesting Generator" => 208,
      "Manifestor" => 203,
      "Projector" => 75,
      "Reflector" => 141
    }.freeze

    CENTER_COLORS = {
      "Head" => 221, "Ajna" => 71, "Throat" => 173, "G" => 221, "Heart" => 167,
      "Spleen" => 173, "SolarPlexus" => 173, "Sacral" => 167, "Root" => 173
    }.freeze

    CENTER_LABELS = {
      "Head" => "HEAD", "Ajna" => "AJNA", "Throat" => "THROAT", "G" => "G",
      "Heart" => "HEART", "Spleen" => "SPLEEN", "SolarPlexus" => "SOLAR",
      "Sacral" => "SACRAL", "Root" => "ROOT"
    }.freeze

    GLYPHS = {
      "Sun" => "☉", "Earth" => "⊕", "Moon" => "☽", "NorthNode" => "☊",
      "SouthNode" => "☋", "Mercury" => "☿", "Venus" => "♀", "Mars" => "♂",
      "Jupiter" => "♃", "Saturn" => "♄", "Uranus" => "♅", "Neptune" => "♆",
      "Pluto" => "♇"
    }.freeze

    LINE_NAMES = {
      1 => "Investigator", 2 => "Hermit", 3 => "Martyr",
      4 => "Opportunist", 5 => "Heretic", 6 => "Role Model"
    }.freeze

    NUMBER_MEANINGS = {
      1 => "Initiator · independence, leadership",
      2 => "Peacemaker · partnership, sensitivity",
      3 => "Expresser · creativity, joy",
      4 => "Builder · structure, discipline",
      5 => "Explorer · change, freedom",
      6 => "Nurturer · care, responsibility",
      7 => "Seeker · analysis, inner wisdom",
      8 => "Achiever · power, abundance",
      9 => "Humanitarian · compassion, completion",
      11 => "Illuminator (master) · intuition, inspiration",
      22 => "Master Builder (master) · vision made real",
      33 => "Master Teacher (master) · healing, service"
    }.freeze

    def initialize(chart, numerology: nil)
      @chart = chart
      @numerology = numerology
    end

    def render
      banner
      type_card
      bodygraph
      centers
      channels
      stats
      activations
      numerology_card if numerology
      footer
    end

    private

    attr_reader :chart, :numerology

    def paint(text, *codes)
      Ansi.paint(text, *codes)
    end

    def graph
      chart.body_graph
    end

    # ── layout helpers ───────────────────────────────────────────────────────

    def section(title)
      puts
      rule = "─" * [WIDTH - title.length - 6, 3].max
      puts "  #{paint('━━ ', Ansi.fg(FRAME))}#{paint(title, Ansi.fg(ACCENT), '1')} #{paint(rule, Ansi.fg(FRAME))}"
    end

    def field(label, value)
      puts "    #{paint(label.ljust(13), '2')}#{value}"
    end

    def gauge(label, value, max, width = 24)
      filled = max.zero? ? 0 : (value.to_f / max * width).round
      cells = paint("█" * filled, Ansi.fg(ACCENT)) + paint("░" * (width - filled), Ansi.fg(FRAME))
      puts "    #{label.ljust(10)} #{cells}  #{paint("#{value}/#{max}", '1')}"
    end

    def gate_color(number)
      in_p = chart.personality.gate_numbers.include?(number)
      in_d = chart.design.gate_numbers.include?(number)
      return BOTH if in_p && in_d

      in_d ? DESIGN : PERSONALITY
    end

    def gate_label(number, hanging: false)
      styles = [Ansi.fg(gate_color(number)), "1"]
      styles << "4" if hanging
      paint(number.to_s.rjust(2), *styles)
    end

    # ── sections ─────────────────────────────────────────────────────────────

    def banner
      edge = paint("│", Ansi.fg(FRAME))
      title = paint("✦  H U M A N   D E S I G N  ✦", Ansi.fg(ACCENT), "1")
      born = paint("born #{chart.birth}", "2")
      puts
      puts "  #{paint("╭#{'─' * (WIDTH - 2)}╮", Ansi.fg(FRAME))}"
      ["", title, born, ""].each do |text|
        puts "  #{edge}#{Ansi.center(text, WIDTH - 2)}#{edge}"
      end
      puts "  #{paint("╰#{'─' * (WIDTH - 2)}╯", Ansi.fg(FRAME))}"
    end

    def type_card
      color = TYPE_COLORS.fetch(chart.type)
      puts
      puts "    #{paint('◆', Ansi.fg(color))} #{paint(chart.type.upcase, Ansi.fg(color), '1')}"
      puts
      field("Strategy", chart.strategy)
      field("Not-self", chart.not_self_theme)
      field("Authority", chart.authority)
      field("Profile", "#{paint(chart.profile, '1')}  #{profile_names}")
      field("Definition", graph.definition_type)
      return unless graph.components.size > 1

      parts = graph.components.map { |comp| comp.sort.join("+") }
      puts "    #{' ' * 13}#{paint(parts.join('  │  '), '2')}"
    end

    def profile_names
      names = [chart.personality.sun_gate.line, chart.design.sun_gate.line].map { |l| LINE_NAMES[l] }
      paint(names.join(" / "), "2")
    end

    # A sketch of the BodyGraph. Filled blocks are defined centers, outlines
    # are open ones; a bold link means a channel joins those two centers.
    def bodygraph
      section("BODYGRAPH")
      puts
      show(mid: box("Head"))
      vlink("Head", "Ajna")
      show(mid: box("Ajna"))
      vlink("Ajna", "Throat")
      show(mid: box("Throat"))
      vlink("Throat", "G")
      show(mid: box("G"), right: box("Heart"), right_link: linked?("G", "Heart"))
      vlink("G", "Sacral")
      show(left: box("Spleen"), left_link: linked?("Spleen", "Sacral"), mid: box("Sacral"),
           right: box("SolarPlexus"), right_link: linked?("Sacral", "SolarPlexus"))
      vlink("Sacral", "Root")
      show(mid: box("Root"))
      puts
      puts "    #{paint('Adjacent links only; long-range channels are listed below.', '2')}"
    end

    def linked?(first, second)
      graph.active_channels.any? { |ch| ch.centers.sort == [first, second].sort }
    end

    def box(name)
      label = CENTER_LABELS.fetch(name)
      color = CENTER_COLORS.fetch(name)
      if graph.defined_centers.include?(name)
        return ["█" * 9, "█#{Ansi.center(label, 7)}█", "█" * 9] unless Ansi.enabled?

        blank = paint(" " * 9, Ansi.bg(color))
        [blank, paint(Ansi.center(label, 9), Ansi.bg(color), Ansi.fg(16), "1"), blank]
      else
        style = [Ansi.fg(color), "2"]
        [paint("╭#{'─' * 7}╮", *style),
         paint("│#{Ansi.center(label, 7)}│", *style),
         paint("╰#{'─' * 7}╯", *style)]
      end
    end

    def gap(flag)
      case flag
      when nil then " " * 5
      when true then paint("━" * 5, Ansi.fg(ACCENT), "1")
      else paint("·" * 5, "2")
      end
    end

    def show(left: nil, left_link: nil, mid: nil, right: nil, right_link: nil)
      blank = " " * 9
      3.times do |i|
        left_gap = i == 1 && left ? gap(left_link) : " " * 5
        right_gap = i == 1 && right ? gap(right_link) : " " * 5
        puts (" " * INDENT + (left ? left[i] : blank) + left_gap +
              (mid ? mid[i] : blank) + right_gap + (right ? right[i] : blank)).rstrip
      end
    end

    def vlink(first, second)
      glyph = linked?(first, second) ? paint("┃", Ansi.fg(ACCENT), "1") : paint("┊", "2")
      puts " " * (INDENT + MID + 4) + glyph
    end

    def centers
      section("CENTERS")
      puts "    #{paint('●', Ansi.fg(PERSONALITY))} conscious  " \
           "#{paint('●', Ansi.fg(DESIGN))} design  " \
           "#{paint('●', Ansi.fg(BOTH))} both  #{paint('underline', '4')} hanging gate"
      puts
      hanging = graph.hanging_gates
      Center::ALL.each do |name|
        defined = graph.defined_centers.include?(name)
        mark = defined ? paint("●", Ansi.fg(CENTER_COLORS[name])) : paint("○", "2")
        state = defined ? "defined" : paint("open", "2")
        gates = Center::GATES_BY_NAME[name].select { |g| graph.active_gate_numbers.include?(g) }.sort
        shown = gates.map { |g| gate_label(g, hanging: hanging.include?(g)) }.join(" ")
        puts "    #{mark} #{Ansi.pad(name, 12)}#{Ansi.pad(state, 9)}#{shown}"
      end
    end

    def channels
      list = graph.active_channels.sort_by { |c| c.gates.min }
      section("CHANNELS (#{list.size})")
      puts
      if list.empty?
        puts "    #{paint('none', '2')}"
        return
      end
      list.each do |channel|
        low, high = channel.gates.sort
        gates = "#{gate_label(low)} #{paint('━', Ansi.fg(FRAME))} #{gate_label(high)}"
        names = channel.centers.map { |c| CENTER_LABELS.fetch(c).capitalize }.join(paint(" ⇄ ", "2"))
        puts "    #{gates}   #{names}"
      end
    end

    def stats
      section("ENERGY")
      puts
      gauge("Centers", graph.defined_centers.size, Center::ALL.size)
      gauge("Channels", graph.active_channels.size, Channel.all.size)
      gauge("Gates", graph.active_gate_numbers.size, 64)
      puts

      conscious = chart.personality.gate_numbers
      design = chart.design.gate_numbers
      both = conscious & design
      puts "    #{paint(conscious.size - both.size, Ansi.fg(PERSONALITY), '1')} conscious-only  " \
           "#{paint('·', '2')}  #{paint(design.size - both.size, Ansi.fg(DESIGN), '1')} design-only  " \
           "#{paint('·', '2')}  #{paint(both.size, Ansi.fg(BOTH), '1')} in both"
      puts
      line_histogram
    end

    def line_histogram
      counts = Hash.new(0)
      [chart.personality, chart.design].each do |set|
        set.each_gate { |_planet, gate| counts[gate.line] += 1 }
      end
      top = [counts.values.max.to_i, 1].max
      puts "    #{paint('Lines across all 26 activations', '2')}"
      (1..6).each do |line|
        filled = (counts[line].to_f / top * 20).round
        cells = paint("█" * filled, Ansi.fg(ACCENT)) + paint("░" * (20 - filled), Ansi.fg(FRAME))
        puts "    #{line} #{Ansi.pad(LINE_NAMES[line], 13)}#{cells}  #{counts[line]}"
      end
    end

    def activations
      section("ACTIVATIONS")
      puts
      head = "#{paint('●', Ansi.fg(PERSONALITY))} Personality"
      puts "    #{' ' * 13}#{Ansi.pad(head, 24)}#{paint('●', Ansi.fg(DESIGN))} Design"
      puts "    #{paint('─' * 52, Ansi.fg(FRAME))}"
      Planet::ALL.each do |name|
        row = [chart.personality, chart.design].each_with_index.map do |set, index|
          gate = set.gate_for(name)
          color = index.zero? ? PERSONALITY : DESIGN
          cell = "#{paint(gate.to_s.rjust(4), Ansi.fg(color), '1')} #{paint(gate.center.to_s, '2')}"
          Ansi.pad(cell, 20)
        end
        puts "    #{GLYPHS.fetch(name)} #{Ansi.pad(name, 11)}#{row.join(' ')}"
      end
    end

    def numerology_card
      section("NUMEROLOGY · #{numerology.full_name}")
      puts
      [
        ["Life Path", numerology.life_path_number],
        ["Birthday", numerology.birthday_number],
        ["Expression", numerology.expression_number],
        ["Soul Urge", numerology.soul_urge_number],
        ["Personality", numerology.personality_number]
      ].each do |label, number|
        master = Numerology::MASTER_NUMBERS.include?(number)
        badge = paint(number.to_s.rjust(2), Ansi.fg(master ? 221 : ACCENT), "1")
        star = master ? paint("✦", Ansi.fg(221)) : " "
        puts "    #{label.ljust(12)} #{badge} #{star} #{paint(NUMBER_MEANINGS.fetch(number), '2')}"
      end
    end

    def footer
      puts
      puts "  #{paint('─' * (WIDTH - 2), Ansi.fg(FRAME))}"
      puts "  #{paint('Verify against myBodyGraph or Genetic Matrix. Wheel offset and True Node', '2')}"
      puts "  #{paint('match mainstream software; a line can shift near a gate boundary.', '2')}"
      puts
    end
  end
end

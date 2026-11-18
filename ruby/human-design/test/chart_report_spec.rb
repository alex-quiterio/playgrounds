require 'test_helper'

describe HumanDesign::ChartReport do
  def render(chart, numerology: nil, color: false)
    env = color ? { 'NO_COLOR' => nil, 'FORCE_COLOR' => '1' } : { 'NO_COLOR' => '1' }
    out = nil
    with_env(env) do
      out, = capture_io { HumanDesign::ChartReport.new(chart, numerology: numerology).render }
    end
    out
  end

  let(:chart) { chart_with(5, 15, 21, 45) } # Manifesting Generator, split definition

  it 'shows the banner with the birth data' do
    out = render(chart)
    assert_includes out, 'H U M A N   D E S I G N'
    assert_includes out, 'born 14/3/1990 09:30 (UTC+1)'
  end

  it 'shows the type card' do
    out = render(chart)
    assert_includes out, 'MANIFESTING GENERATOR'
    assert_includes out, 'To respond, then inform'
    assert_includes out, 'Frustration and Anger'
    assert_includes out, 'Sacral'
    assert_match(/Profile\s+5\/1\s+Heretic \/ Investigator/, out)
    assert_match(/Definition\s+Split Definition/, out)
  end

  it 'lists the components of a split definition' do
    assert_match(/G\+Sacral\s+│\s+Heart\+Throat/, render(chart))
  end

  it 'lists each section' do
    out = render(chart)
    ['BODYGRAPH', 'CENTERS', 'CHANNELS (2)', 'ENERGY', 'ACTIVATIONS'].each do |title|
      assert_includes out, title
    end
  end

  it 'marks defined and open centers' do
    out = render(chart)
    assert_match(/● Sacral\s+defined/, out)
    assert_match(/○ Head\s+open/, out)
    assert_includes out, '█', 'defined centers are drawn as solid blocks without colour'
    assert_includes out, '╭───────╮', 'open centers are outlined'
  end

  it 'lists channels with their gates and centers' do
    out = render(chart)
    assert_match(/ 5 ━ 15\s+Sacral ⇄ G/, out)
    assert_match(/21 ━ 45\s+Heart ⇄ Throat/, out)
  end

  it 'says so when there are no channels' do
    out = render(chart_with)
    assert_includes out, 'CHANNELS (0)'
    assert_match(/none/, out)
    assert_includes out, 'REFLECTOR'
  end

  it 'shows every planet in the activations table' do
    out = render(chart)
    HumanDesign::Planet::ALL.each { |name| assert_includes out, name }
    assert_includes out, '☉'
  end

  it 'shows the energy gauges and line histogram' do
    out = render(chart)
    assert_match(%r{Centers\s+\S+\s+4/9}, out)
    assert_match(%r{Channels\s+\S+\s+2/36}, out)
    assert_includes out, 'Lines across all 26 activations'
    assert_includes out, 'Investigator'
  end

  it 'leaves numerology out unless asked' do
    refute_includes render(chart), 'NUMEROLOGY'
  end

  it 'renders numerology with meanings and flags master numbers' do
    birth = chart.birth
    numerology = HumanDesign::Numerology.new('Alex Quiterio', birth)
    out = render(chart, numerology: numerology)
    assert_includes out, 'NUMEROLOGY · Alex Quiterio'
    assert_match(/Life Path\s+9\s+Humanitarian/, out)
    assert_match(/Soul Urge\s+11 ✦ Illuminator/, out)
  end

  it 'uses no escape codes when colour is off' do
    refute_includes render(chart), "\e["
  end

  it 'uses escape codes when colour is on, and the same words' do
    colored = render(chart, color: true)
    assert_includes colored, "\e["
    assert_includes strip_ansi(colored), 'MANIFESTING GENERATOR'
    assert_includes strip_ansi(colored), '5/1'
  end

  it 'draws the same layout with and without colour' do
    plain_lines = render(chart).lines.size
    colored_lines = render(chart, color: true).lines.size
    assert_equal plain_lines, colored_lines
  end

  it 'renders a numerology name with accents typed under a US-ASCII locale' do
    name = nil
    with_input("José Quitério\n".dup.force_encoding(Encoding::US_ASCII)) do
      capture_io { name = HumanDesign::Prompt.text('Name') }
    end
    numerology = HumanDesign::Numerology.new(name, chart.birth)
    out = render(chart, numerology: numerology)
    assert_includes out, 'NUMEROLOGY · José Quitério'
  end
end

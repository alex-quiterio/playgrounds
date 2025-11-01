# Day 12: JSAbacusFramework.io
require 'json'

# Adds up every number in the document. With `skip_red`, an object (but not
# an array) holding the value "red" counts as nothing, children included.
def total(value, skip_red:)
  case value
  when Integer then value
  when Array then value.sum { |v| total(v, skip_red:) }
  when Hash
    return 0 if skip_red && value.value?('red')

    value.values.sum { |v| total(v, skip_red:) }
  else 0
  end
end

document = JSON.parse(File.read(ARGV.fetch(0)))
puts total(document, skip_red: false)
puts total(document, skip_red: true)

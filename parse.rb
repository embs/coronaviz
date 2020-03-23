require 'byebug'
require 'json'
require 'pdf-reader'

ROMAN_NUMERALS = %w[
  I
  II
  III
  IV
  V
  VI
  VII
  VIII
  IX
  X
  XI
  XII
]

reader = PDF::Reader.new('report-19.pdf')

cities_numbers = reader.pages.each_with_object({}).with_index do |(page, cities_numbers), index|
  next unless index == 3

  cities_indexes = 7..52
  page.text.split("\n").reject { |s| s == '' }.each_with_index do |city_line, index|
    next unless cities_indexes.include?(index)
    next if city_line.match?('Subtotal')

    numbers = city_line.split(' ')
    city_name = numbers.shift(numbers.size - 5)
    city_name = if ROMAN_NUMERALS.include?(city_name[0])
                  city_name.drop(1).join(' ')
                else
                  city_name.join(' ')
                end

    cities_numbers[city_name] = numbers
  end
end

File.open('pe-cities-numbers.json', 'w') do |f|
  f.write(JSON.pretty_generate(cities_numbers))
end

require 'ratistics'
#require 'rmagick'
require 'gruff'

load File.join(File.dirname(__FILE__), '../support/survey.rb')

sample = Survey.get_pregnancy_data

first = sample.filter{|item| item[:birthord] == 1}
not_first = sample.filter{|item| item[:birthord] > 1}

first_freq = Ratistics.frequency(first){|datum| datum[:prglength]}
not_first_freq = Ratistics.frequency(not_first){|datum| datum[:prglength]}

first_freq_hist = (25..45).inject([]) do |memo, i|
  memo << first_freq[i] || 0
end

not_first_freq_hist = (25..45).inject([]) do |memo, i|
  memo << not_first_freq[i] || 0
end

g = Gruff::Bar.new
g.title = "Histogram"
g.labels = (25..45).inject({}) do |memo, i|
  if i % 5 == 0
    memo[i-25] = i.to_s
  else
    memo[i-25] = ''
  end
  memo
end

g.data(:'first babies', first_freq_hist, '#990000')
g.data(:'others', not_first_freq_hist, '#009900')

g.minimum_value = 0
g.write(File.join(File.dirname(__FILE__), 'histogram.png'))

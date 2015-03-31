#= writeCards
#
#writeCards is a script that takes a array of hashes and saves the hash's
#keys and values in a format to be used by the Anki flashcard app
#
#* Each hash represents a chapter
#* Each key is a word in the original language
#* Each value is the English translation of the key
#
#Similar code appears in +bookParser.rb+
#
#--
# Just playing with rdoc above
#++

require 'json'

buffer = File.open('dict', 'r').read
dict = JSON.parse(buffer)

(0..dict.size-1).each do |i|
  out = File.new("cards/Chapter#{i+1}.txt", 'w')
  dict[i].each do |key, value|
    out.puts "#{key}\t#{value}"
  end
  out.close
end


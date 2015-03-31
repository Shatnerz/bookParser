# encoding: utf-8
#
# Use -F to Force creation of dictionary file even if they already exist

require_relative "pdftohtml"
require_relative "translate"
require 'json'

filepaths = ARGV.select {|i| File.exist?(i)}
filepaths.each do |filepath| #take care of all files passed as arguments
  name = File.basename(filepath, '.pdf') #remove pdf extension
  puts "Starting book: #{name}"
  
  if !File.exist?(File.join('dicts',name+'_nochap_dict')) || ARGV.include?('-F')
    puts "Creating dictionary"
    xml = pdf_to_xml(filepath)
    book = xml.text #book in text format
    
    #words = {} #hash for words of book - {french => english}
    yandex = Translator.new
    
    words  = book.gsub(/[\.\?,!»—«:;\(\)]/, ' ').split #remove punct and split words into arry
    words = words.select {|word| word.size > 3} #remove all words that are 3 characters or less
    words  = words.map{|word| word.downcase}.uniq #downcase words and remove duplicates
    words = Hash[words.zip(yandex.translate(words))]
    
    File.open("dicts/#{name}_nochap_dict", 'w') {|out| out.write(words.to_json)} #save translation in json format
  
  else
    puts "Dictionary found"
    buffer = File.open("dicts/#{name}_nochap_dict", 'r').read
    words = JSON.parse(buffer)
  end
  
  #Create flashcard files
  puts "Creating cards"
  out = File.new("cards/#{name}.txt", 'w')
  words.each do |key, value|
    out.puts "#{key}\t#{value}"
  end
  out.close
  puts "#{name} complete\n\n"
end

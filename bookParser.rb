# encoding: utf-8
# Use -F to Force creation of dictionary file even if they already exist
#
# Splitting for chapters only seems to work with the first hp book
# Should probably just remove that so this script would work generally

require_relative "pdftohtml"
require_relative "translate"
require 'json'

filepaths = ARGV.select {|i| File.exist?(i)}
filepaths.each do |filepath| #take care of all files passed as arguments
  name = File.basename(filepath, '.pdf') #remove pdf extension
  puts "Starting book: #{name}"
  
  if !File.exist?(File.join('dicts',name+'_dict')) || ARGV.include?('-F')
    puts "Creating dictionary"
    xml = pdf_to_xml(filepath)
    book = xml.text #book in text format
    #break book into chapters using the word for chapter
    #also uses '?:' to suppress subexpression and uses '?!' for negative lookahead
    #need to read up on regex more
    chapters = book.scan( /^Chapitre(?:(?!Chapitre).)*/mi ) #works for book 1
    #regex for book 2 and 3 at least (2 adds some garbage chapters)
    # /^\d+\s[[A-ZÀÂÄÈÉÊËÎÏÔŒÙÛÜŸ\-&'l]*\s]*\n(?:(?!^\d+\s[[A-ZÀÂÄÈÉÊËÎÏÔŒÙÛÜŸ\-&'l]*\s]*\n).)*/m
    if chapters.size < 5 #try different regex
      chapters = book.scan(/^\d+\s[[A-ZÀÂÄÈÉÊËÎÏÔŒÙÛÜŸ\-&'l]*\s]*\n(?:(?!^\d+\s[[A-ZÀÂÄÈÉÊËÎÏÔŒÙÛÜŸ\-&'l]*\s]*\n).)*/m)
    end
    
    words = [[]] #multidim array for words of book - [chap]{french => english}
    yandex = Translator.new
    
    chapters = chapters.select {|chapter| chapter.size > 80} #remove small chapters
    #small chapters are probably just pulled from the table of contents
    
    (0..chapters.length-1).each do |i|
      puts "Translating Chapter #{i+1}"
      chapter = chapters[i]
      chapter_words  = chapter.gsub(/[\.\?,!»—«:;]/, ' ').split #remove punct and split words into arry
      chapter_words  = chapter_words.map{|word| word.downcase}.uniq #downcase words and remove duplicates
      words[i] = Hash[chapter_words.zip(yandex.translate(chapter_words))]
    end
    
    File.open("dicts/#{name}_dict", 'w') {|out| out.write(words.to_json)} #save translation in json format
  
  else
    puts "Dictionary found"
    buffer = File.open("dicts/#{name}_dict", 'r').read
    words = JSON.parse(buffer)
  end
  
  #Create flashcard files
  puts "Creating cards"
  (0..words.size-1).each do |i|
    Dir.mkdir("cards/#{name}") unless Dir.exists?("cards/#{name}")
    out = File.new("cards/#{name}/Chapter#{i+1}.txt", 'w')
    words[i].each do |key, value|
      out.puts "#{key}\t#{value}"
    end
    out.close
  end
  puts "#{name} complete\n\n"
end

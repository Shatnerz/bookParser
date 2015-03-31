# encoding: utf-8
require 'open-uri'
require 'uri'
require 'json'

# Class that utilizes the Yandex API to translate words
class Translator
  # key is required for Yandex API
  def initialize(key="trnsl.1.1.20150306T044912Z.6d2b245c7670e6ab.c8891383e66cc0debd50e6e32905fdc99da3ddea"
)
    @key = key
    @lang_from = 'fr'
    @lang_to = 'en'
  end

  # translates an array of words and outputs and array of the tranlations
  def translate(lang_from = @lang_from, lang_to = @lang_to, words)
    return [] if words.size == 0
    all_translated = [] #array of all translated words
    words.each_slice(800) do |slice| #slice into 1000 words doing >1000 runs into problems
      words_string = slice.join("&text=")
      uri = "https://translate.yandex.net/api/v1.5/tr.json/translate?key=APIkey&lang=FROM-TO&text=WORD"
      uri = uri.sub("WORD",words_string).sub("FROM", lang_from).sub("TO", lang_to).sub("APIkey", @key)
      uri = URI.escape(uri) #escape unsafe characters in uri
      begin
        #puts uri
        #puts '****************************'
        json = open(uri).read #open uri of yandex translation
      rescue => e
        puts e.message
      end
      translated = JSON.parse(json)["text"]
      #should probably check to make sure translated != nil
      if translated.nil?
        puts "PROBLEM TRANSLATING - returned nil (URI may be too long)"
      else
        all_translated += translated
      end
    end
    all_translated #return array of all translations
  end
end

#yandex = Translator.new
#puts yandex.translate(["survivant", "grand", "homme", "l'actionna", "aperçut"])

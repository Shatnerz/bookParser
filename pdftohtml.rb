#encoding: utf-8

#Uses pdftohtml to return an xml of the pdf
#Does not extract images

require 'shellwords'
require 'nokogiri'

def pdf_to_xml(path)
  cmd = "pdftohtml -xml -i -stdout #{path.shellescape}"
  xml = `#{cmd}`
  xml_doc = Nokogiri::XML(xml)
end

#filepath = "books/01_Harry_Potter_à_l'École_des_Sorciers.pdf"
#puts pdf_to_xml(filepath).text

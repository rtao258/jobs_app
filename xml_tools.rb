# https://gist.github.com/wteuber/5524513

require 'nokogiri'

# Print pretty XML
# @param [String] xml
# @return [String] xml
def pp_xml(xml)
  doc = Nokogiri.XML(xml) do |config|
    config.default_xml.noblanks
  end
  puts doc.to_xml(:indent => 2)
  xml
end

require_relative "RGSS-Extractor/Data-Export"
require_relative "RGSS-Extractor/Data-Import"

def usage
  STDERR.puts "usage: data-extractor.rb import|export"
  exit 1
end

usage if ARGV.length < 1

if ARGV[0] == "import"
  import
elsif ARGV[0] == "export"
  export
else
  usage
end

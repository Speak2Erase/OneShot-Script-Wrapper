STDERR.puts "No Data Directory!" unless Dir.exists? "Data"
exit 1 unless Dir.exists? "Data"

require "json"
require "ruby-progressbar"
require "fileutils"
require "pathname"
require_relative "Classnames"

puts "exporting..."
Dir.mkdir "Data_JSON" unless Dir.exists? "Data_JSON"
paths = Pathname.glob(("Data/" + ("*" + ".rxdata")))
count = paths.size
progress = ProgressBar.create(format: "%a |%b>>%i| %p%% %t", starting_at: 0, total: count, output: $stderr)
paths.each_with_index do |path, i|
  content = Hash.new

  name = path.basename(".rxdata")
  rxdata = Marshal.load(path.read(mode: "rb"))
  #puts name.to_s
  case name.to_s

  when "Scripts"
  when "MapInfos"
    content = {}
    mapinfos = rxdata.sort_by { |key, value| value.parent_id }.to_h
    mapinfos.each do |key, value|
      content[key] = value._dump
    end
  when /^Map\d+$/
    content[:events] = {}
    events = (rxdata.instance_variable_get(:@events).sort_by { |key| key }.to_h)
    events.each do |key, value|
      content[:events][key] = value._dump
    end
    content[:data] = rxdata.instance_variable_get(:@data)._dump
    content[:autoplay_bgm] = rxdata.instance_variable_get(:@autoplay_bgm)
    content[:autoplay_bgs] = rxdata.instance_variable_get(:@autoplay_bgs)
    content[:bgm] = rxdata.instance_variable_get(:@bgm)._dump
    content[:bgs] = rxdata.instance_variable_get(:@bgs)._dump
    content[:encounter_list] = rxdata.instance_variable_get(:@encounter_list)
    content[:encounter_step] = rxdata.instance_variable_get(:@encounter_step)
    content[:height] = rxdata.instance_variable_get(:@height)
    content[:width] = rxdata.instance_variable_get(:@width)
    content[:tileset_id] = rxdata.instance_variable_get(:@tileset_id)
  else
  end

  json = File.open("Data_JSON/" + name.sub_ext(".json").to_s, "wb")
  #puts content
  json.puts JSON.pretty_generate(content)

  progress.increment
end
puts
puts "export completed."

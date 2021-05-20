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

  when "System"
    content = {
      magic_number: rxdata.instance_variable_get(:@magic_number),
      party_members: rxdata.instance_variable_get(:@party_members),
      elements: rxdata.instance_variable_get(:@elements),
      switches: rxdata.instance_variable_get(:@switches),
      variables: rxdata.instance_variable_get(:@variables),
      windowskin_name: rxdata.instance_variable_get(:@windowskin_name),
      title_name: rxdata.instance_variable_get(:@title_name),
      gameover_name: rxdata.instance_variable_get(:@gameover_name),
      battle_transition: rxdata.instance_variable_get(:@battle_transition),

      title_bgm: rxdata.instance_variable_get(:@title_bgm)._dump,
      battle_bgm: rxdata.instance_variable_get(:@battle_bgm)._dump,

      battle_end_me: rxdata.instance_variable_get(:@battle_end_me)._dump,
      gameover_me: rxdata.instance_variable_get(:@gameover_me)._dump,

      cursor_se: rxdata.instance_variable_get(:@cursor_se)._dump,
      decision_se: rxdata.instance_variable_get(:@decision_se)._dump,
      cancel_se: rxdata.instance_variable_get(:@cancel_se)._dump,
      buzzer_se: rxdata.instance_variable_get(:@buzzer_se)._dump,
      equip_se: rxdata.instance_variable_get(:@equip_se)._dump,
      shop_se: rxdata.instance_variable_get(:@shop_se)._dump,
      save_se: rxdata.instance_variable_get(:@save_se)._dump,
      load_se: rxdata.instance_variable_get(:@load_se)._dump,
      battle_start_se: rxdata.instance_variable_get(:@battle_start_se)._dump,
      escape_se: rxdata.instance_variable_get(:@escape_se)._dump,
      actor_collapse_se: rxdata.instance_variable_get(:@actor_collapse_se)._dump,
      enemy_collapse_se: rxdata.instance_variable_get(:@enemy_collapse_se)._dump,

      words: rxdata.instance_variable_get(:@words)._dump,

      test_battlers: [],
      test_troop_id: rxdata.instance_variable_get(:@test_troop_id),
      start_map_id: rxdata.instance_variable_get(:@start_map_id),
      start_x: rxdata.instance_variable_get(:@start_x),
      start_y: rxdata.instance_variable_get(:@start_y),
      battleback_name: rxdata.instance_variable_get(:@battleback_name),
      battler_name: rxdata.instance_variable_get(:@battler_name),
      battler_hue: rxdata.instance_variable_get(:@battler_hue),
      edit_map_id: rxdata.instance_variable_get(:@edit_map_id),
    }
    rxdata.instance_variable_get(:@test_battlers).each_with_index do |val, index|
      content[:test_battlers] << rxdata.instance_variable_get(:@test_battlers)[index]._dump
    end
  when "MapInfos"
    content = {}
    mapinfos = rxdata.sort_by { |key, value| value.parent_id }.to_h
    mapinfos.each do |key, value|
      content[key] = value._dump
    end
  when "CommonEvents"
    content[:common_events] = []
    rxdata.each_with_index do |value, index|
      content[:common_events] << rxdata[index]._dump unless rxdata[index] == nil
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

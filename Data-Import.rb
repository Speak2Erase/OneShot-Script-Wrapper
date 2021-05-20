STDERR.puts "No Data_JSON Directory!" unless Dir.exists? "Data_JSON"
exit 1 unless Dir.exists? "Data_JSON"

require "oj"
require "ruby-progressbar"
require "fileutils"
require "pathname"
require_relative "Classnames"

#progress = ProgressBar.create(
#  format: "%a /%e |%B| %p%% %c/%C %r files/sec %t",
#  starting_at: 0,
#  total: nil,
#  output: $stderr,
#  length: 150,
#  title: "Exported",
#  remainder_mark: "\e[0;30m█\e[0m",
#  progress_mark: "█",
#  unknown_progress_animation_steps: ["==>", ">==", "=>="],
#)
Dir.mkdir "Data_Test" unless Dir.exists? "Data_Test"
paths = Pathname.glob(("Data_JSON/" + ("*" + ".json")))
count = paths.size
#progress.total = count
paths.each_with_index do |path, i|
  content = Hash.new

  name = path.basename(".json")
  json = Oj.load path.read(mode: "rb")
  #puts name.to_s
  case name.to_s
  when "xScripts"
  when "Scripts"
    #when "System"
    #  content = {
    #    magic_number: json.instance_variable_get(:@magic_number),
    #    party_members: json.instance_variable_get(:@party_members),
    #    elements: json.instance_variable_get(:@elements),
    #    switches: json.instance_variable_get(:@switches),
    #    variables: json.instance_variable_get(:@variables),
    #    windowskin_name: json.instance_variable_get(:@windowskin_name),
    #    title_name: json.instance_variable_get(:@title_name),
    #    gameover_name: json.instance_variable_get(:@gameover_name),
    #    battle_transition: json.instance_variable_get(:@battle_transition),
    #
    #    title_bgm: json.instance_variable_get(:@title_bgm).hash,
    #    battle_bgm: json.instance_variable_get(:@battle_bgm).hash,
    #
    #    battle_end_me: json.instance_variable_get(:@battle_end_me).hash,
    #    gameover_me: json.instance_variable_get(:@gameover_me).hash,
    #
    #    cursor_se: json.instance_variable_get(:@cursor_se).hash,
    #    decision_se: json.instance_variable_get(:@decision_se).hash,
    #    cancel_se: json.instance_variable_get(:@cancel_se).hash,
    #    buzzer_se: json.instance_variable_get(:@buzzer_se).hash,
    #    equip_se: json.instance_variable_get(:@equip_se).hash,
    #    shop_se: json.instance_variable_get(:@shop_se).hash,
    #    save_se: json.instance_variable_get(:@save_se).hash,
    #    load_se: json.instance_variable_get(:@load_se).hash,
    #    battle_start_se: json.instance_variable_get(:@battle_start_se).hash,
    #    escape_se: json.instance_variable_get(:@escape_se).hash,
    #    actor_collapse_se: json.instance_variable_get(:@actor_collapse_se).hash,
    #    enemy_collapse_se: json.instance_variable_get(:@enemy_collapse_se).hash,
    #
    #    words: json.instance_variable_get(:@words).hash,
    #
    #    test_battlers: [],
    #    test_troop_id: json.instance_variable_get(:@test_troop_id),
    #    start_map_id: json.instance_variable_get(:@start_map_id),
    #    start_x: json.instance_variable_get(:@start_x),
    #    start_y: json.instance_variable_get(:@start_y),
    #    battleback_name: json.instance_variable_get(:@battleback_name),
    #    battler_name: json.instance_variable_get(:@battler_name),
    #    battler_hue: json.instance_variable_get(:@battler_hue),
    #    edit_map_id: json.instance_variable_get(:@edit_map_id),
    #  }
    #  json.instance_variable_get(:@test_battlers).each_with_index do |val, index|
    #    content[:test_battlers] << json.instance_variable_get(:@test_battlers)[index].hash
    #  end
  when "MapInfos"
    content = {}
    json.each do |key, value|
      content[key.to_i] = RPG::MapInfo.new
      content[key.to_i].load json[key]
    end
    #when "CommonEvents"
    #when /^Map\d+$/
    #  content[:events] = {}
    #  events = (json.instance_variable_get(:@events).sort_by { |key| key }.to_h)
    #  events.each do |key, value|
    #    content[:events][key] = value.hash
    #  end
    #  content[:data] = json.instance_variable_get(:@data).hash
    #  content[:autoplay_bgm] = json.instance_variable_get(:@autoplay_bgm)
    #  content[:autoplay_bgs] = json.instance_variable_get(:@autoplay_bgs)
    #  content[:bgm] = json.instance_variable_get(:@bgm).hash
    #  content[:bgs] = json.instance_variable_get(:@bgs).hash
    #  content[:encounter_list] = json.instance_variable_get(:@encounter_list)
    #  content[:encounter_step] = json.instance_variable_get(:@encounter_step)
    #  content[:height] = json.instance_variable_get(:@height)
    #  content[:width] = json.instance_variable_get(:@width)
    #  content[:tileset_id] = json.instance_variable_get(:@tileset_id)
    #else
    #  content[name] = []
    #  json.each_with_index do |value|
    #    content[name] << value.hash unless value == nil
    #  end
  end

  rxdata = File.open("Data_Test/" + name.sub_ext(".rxdata").to_s, "wb")
  #puts content
  rxdata.puts Marshal.dump(content)

  #progress.increment
end

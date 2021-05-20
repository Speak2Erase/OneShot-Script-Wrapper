STDERR.puts "No Data Directory!" unless Dir.exists? "Data"
exit 1 unless Dir.exists? "Data"

require "json"
require "ruby-progressbar"
require "fileutils"
require "pathname"
require_relative "Classnames"

progress = ProgressBar.create(
  format: "%a /%e |%B| %p%% %c/%C %r files/sec %t",
  starting_at: 0,
  total: nil,
  output: $stderr,
  length: 150,
  title: "Exported",
  remainder_mark: "\e[0;30m█\e[0m",
  progress_mark: "█",
  unknown_progress_animation_steps: ["==>", ">==", "=>="],
)
Dir.mkdir "Data_JSON" unless Dir.exists? "Data_JSON"
paths = Pathname.glob(("Data/" + ("*" + ".rxdata")))
count = paths.size
progress.total = count
paths.each_with_index do |path, i|
  content = Hash.new

  name = path.basename(".rxdata")
  rxdata = Marshal.load(path.read(mode: "rb"))
  #puts name.to_s
  case name.to_s
  when "xScripts"
  when "Scripts"
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

      title_bgm: rxdata.instance_variable_get(:@title_bgm).hash,
      battle_bgm: rxdata.instance_variable_get(:@battle_bgm).hash,

      battle_end_me: rxdata.instance_variable_get(:@battle_end_me).hash,
      gameover_me: rxdata.instance_variable_get(:@gameover_me).hash,

      cursor_se: rxdata.instance_variable_get(:@cursor_se).hash,
      decision_se: rxdata.instance_variable_get(:@decision_se).hash,
      cancel_se: rxdata.instance_variable_get(:@cancel_se).hash,
      buzzer_se: rxdata.instance_variable_get(:@buzzer_se).hash,
      equip_se: rxdata.instance_variable_get(:@equip_se).hash,
      shop_se: rxdata.instance_variable_get(:@shop_se).hash,
      save_se: rxdata.instance_variable_get(:@save_se).hash,
      load_se: rxdata.instance_variable_get(:@load_se).hash,
      battle_start_se: rxdata.instance_variable_get(:@battle_start_se).hash,
      escape_se: rxdata.instance_variable_get(:@escape_se).hash,
      actor_collapse_se: rxdata.instance_variable_get(:@actor_collapse_se).hash,
      enemy_collapse_se: rxdata.instance_variable_get(:@enemy_collapse_se).hash,

      words: rxdata.instance_variable_get(:@words).hash,

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
      content[:test_battlers] << rxdata.instance_variable_get(:@test_battlers)[index].hash
    end
  when "MapInfos"
    content = {}
    mapinfos = rxdata.sort_by { |key, value| value.order }.to_h
    mapinfos.each do |key, value|
      content[key] = value.hash
    end
  when "CommonEvents"
    content[:common_events] = []
    rxdata.each_with_index do |value|
      content[:common_events] << value.hash unless value == nil
    end
  when /^Map\d+$/
    content[:events] = {}
    events = (rxdata.instance_variable_get(:@events).sort_by { |key| key }.to_h)
    events.each do |key, value|
      content[:events][key] = value.hash
    end
    content[:data] = rxdata.instance_variable_get(:@data).hash
    content[:autoplay_bgm] = rxdata.instance_variable_get(:@autoplay_bgm)
    content[:autoplay_bgs] = rxdata.instance_variable_get(:@autoplay_bgs)
    content[:bgm] = rxdata.instance_variable_get(:@bgm).hash
    content[:bgs] = rxdata.instance_variable_get(:@bgs).hash
    content[:encounter_list] = rxdata.instance_variable_get(:@encounter_list)
    content[:encounter_step] = rxdata.instance_variable_get(:@encounter_step)
    content[:height] = rxdata.instance_variable_get(:@height)
    content[:width] = rxdata.instance_variable_get(:@width)
    content[:tileset_id] = rxdata.instance_variable_get(:@tileset_id)
  else
    content[name] = []
    rxdata.each_with_index do |value|
      content[name] << value.hash unless value == nil
    end
  end

  json = File.open("Data_JSON/" + name.sub_ext(".json").to_s, "wb")
  #puts content
  json.puts JSON.pretty_generate(content)

  progress.increment
end

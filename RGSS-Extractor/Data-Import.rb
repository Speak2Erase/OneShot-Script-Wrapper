def import
  STDERR.puts "No Data_JSON Directory!" unless Dir.exists? "./Data_JSON"
  exit 1 unless Dir.exists? "./Data_JSON"

  require "oj"
  require "ruby-progressbar"
  require "fileutils"
  require "pathname"
  require_relative "Classnames"
  require_relative "Script-Handler"

  progress = ProgressBar.create(
    format: "%a /%e |%B| %p%% %c/%C %r files/sec %t",
    starting_at: 0,
    total: nil,
    output: $stderr,
    length: 150,
    title: "Imported",
    remainder_mark: "\e[0;30m█\e[0m",
    progress_mark: "█",
    unknown_progress_animation_steps: ["==>", ">==", "=>="],
  )
  Dir.mkdir "./Data" unless Dir.exists? "./Data"
  paths = Pathname.glob(("./Data_JSON/" + ("*" + ".json")))
  count = paths.size
  progress.total = count
  paths.each_with_index do |path, i|
    content = Hash.new

    name = path.basename(".json")
    json = Oj.load path.read(mode: "rb")
    #puts name.to_s
    case name.to_s
    when "xScripts"
      rpgscript("./", "./Scripts")
    when "Scripts"
    when "System"
      content = RPG::System.new json
    when "MapInfos"
      content = {}
      json.each do |key, value|
        content[key.to_i] = RPG::MapInfo.new json[key]
      end
      #when "CommonEvents"
    when /^Map\d+$/
      content = RPG::Map.new json

      #! All files that contain an array of subclasses start with nil since they start from 1, not 0

    when "CommonEvents"
      content = [nil]
      json["commonevents"].each_with_index do |value|
        content << RPG::CommonEvent.new(value)
      end
    when "Tilesets"
      content = [nil]
      json["tilesets"].each_with_index do |value|
        content << RPG::Tileset.new(value)
      end
    when "Animations"
      content = [nil]
      json["animations"].each_with_index do |value|
        content << RPG::Animation.new(value)
      end
    when "States"
      content = [nil]
      json["states"].each_with_index do |value|
        content << RPG::State.new(value)
      end
    when "Actors"
      content = [nil]
      json["actors"].each_with_index do |value|
        content << RPG::Actor.new(value)
      end
    when "Skills"
      content = [nil]
      json["skills"].each_with_index do |value|
        content << RPG::Skill.new(value)
      end
    when "Items"
      content = [nil]
      json["items"].each_with_index do |value|
        content << RPG::Item.new(value)
      end
    when "Weapons"
      content = [nil]
      json["weapons"].each_with_index do |value|
        content << RPG::Weapon.new(value)
      end
    when "Armors"
      content = [nil]
      json["armors"].each_with_index do |value|
        content << RPG::Armor.new(value)
      end
    when "Classes"
      content = [nil]
      json["classes"].each_with_index do |value|
        content << RPG::Class.new(value)
      end
    when "Enemies"
      content = [nil]
      json["enemies"].each_with_index do |value|
        content << RPG::Enemy.new(value)
      end
    when "Troops"
      content = [nil]
      json["troops"].each_with_index do |value|
        content << RPG::Troop.new(value)
      end
    end

    rxdata = File.open("./Data/" + name.sub_ext(".rxdata").to_s, "wb")
    rxdata.puts Marshal.dump(content)

    progress.increment
  end
end

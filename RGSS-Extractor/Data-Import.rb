def import
  STDERR.puts "No Data_JSON Directory!" unless Dir.exists? "./Data_JSON"
  exit 1 unless Dir.exists? "./Data_JSON"

  require "oj"
  require "ruby-progressbar"
  require "fileutils"
  require "pathname"
  require "readline"
  require_relative "Classnames"
  require_relative "Script-Handler"

  window_size = (Readline.get_screen_size[1] - 1).clamp(0, 500)
  progress = ProgressBar.create(
    format: "%a /%e |%B| %p%% %c/%C %r files/sec %t",
    starting_at: 0,
    total: nil,
    output: $stderr,
    length: window_size,
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
      progress.increment
      return
    when "Scripts"
    when "System"
      content = RPG::System.new(json)
    when "MapInfos"
      content = {}
      json.each do |key, value|
        content[key.to_i] = RPG::MapInfo.new(value) unless key == "version"
      end
      #when "CommonEvents"
    when /^Map\d+$/
      content = RPG::Map.new json
      #! All files that contain an array of subclasses start with nil since they start from 1, not 0
    else
      content = [nil]
      json[name.to_s.downcase].each_with_index do |value, index|
        eval("content << RPG::#{name.to_s.singularize}.new(value)")
      end
    end

    rxdata = File.open("./Data/" + name.sub_ext(".rxdata").to_s, "wb")
    rxdata.puts Marshal.dump(content)

    progress.increment
  end
end

class String
  def singularize
    if self.end_with? "ies"
      self.delete_suffix("ies") + "y"
    elsif self.end_with? "tes"
      self.delete_suffix("s")
    elsif self.end_with? "es"
      self.delete_suffix("es")
    elsif self.end_with? "s"
      self.delete_suffix("s")
    else
      self
    end
  end
end

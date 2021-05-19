class Color
  attr_accessor :red, :green, :blue, :alpha

  def initialize(red, green, blue, alpha = 255)
    @red, @green, @blue, @alpha = red, green, blue, alpha
  end

  def _dump
    dump = {
      red: @red,
      green: @green,
      blue: @blue,
      alpha: @alpha,
    }
  end

  def self._load(obj)
    Color.new(*obj.unpack("EEEE"))
  end
end

module RPG; end

class RPG::ObjectBase; end
class RPG::Map < RPG::ObjectBase; end
class RPG::Map::Encounter < RPG::ObjectBase; end
class RPG::MapInfo < RPG::ObjectBase; end
class RPG::Event < RPG::ObjectBase; end
class RPG::Event::Page < RPG::ObjectBase; end
class RPG::Event::Page::Condition < RPG::ObjectBase; end
class RPG::Event::Page::Graphic < RPG::ObjectBase; end
class RPG::EventCommand < RPG::ObjectBase; end
class RPG::MoveRoute < RPG::ObjectBase; end
class RPG::MoveCommand < RPG::ObjectBase; end
class RPG::BaseItem < RPG::ObjectBase; end
class RPG::Actor < RPG::BaseItem; end
class RPG::Class < RPG::BaseItem; end
class RPG::Class::Learning < RPG::ObjectBase; end
class RPG::UsableItem < RPG::BaseItem; end
class RPG::Skill < RPG::UsableItem; end
class RPG::Item < RPG::UsableItem; end
class RPG::EquipItem < RPG::BaseItem; end
class RPG::Weapon < RPG::EquipItem; end
class RPG::Armor < RPG::EquipItem; end
class RPG::Enemy < RPG::BaseItem; end
class RPG::Enemy::Action < RPG::ObjectBase; end
class RPG::Troop < RPG::ObjectBase; end
class RPG::Troop::Member < RPG::ObjectBase; end
class RPG::Troop::Page < RPG::ObjectBase; end
class RPG::Troop::Page::Condition < RPG::ObjectBase; end
class RPG::State < RPG::ObjectBase; end
class RPG::Animation < RPG::ObjectBase; end
class RPG::Animation::Frame < RPG::ObjectBase; end
class RPG::Animation::Timing < RPG::ObjectBase; end
class RPG::Tileset < RPG::ObjectBase; end
class RPG::CommonEvent < RPG::ObjectBase; end
class RPG::System < RPG::ObjectBase; end
class RPG::System::Words < RPG::ObjectBase; end
class RPG::System::TestBattler < RPG::ObjectBase; end
class RPG::AudioFile < RPG::ObjectBase; end

class Table
  def initialize(data)
    @num_of_dimensions, @xsize, @ysize, @zsize, @num_of_elements, *@elements = *data
    if @num_of_dimensions > 1
      if @xsize > 1
        @elements = @elements.each_slice(@xsize).to_a
      else
        @elements = @elements.map { |element| [element] }
      end
    end
    if @num_of_dimensions > 2
      if @ysize > 1
        @elements = @elements.each_slice(@ysize).to_a
      else
        @elements = @elements.map { |element| [element] }
      end
    end
  end

  def _dump
    dump = {
      dimensions: @num_of_dimensions,
      width: @xsize,
      height: @ysize,
      depth: @zsize,
      size: @num_of_elements,
      elements: [],
    } #.pack("VVVVVv*")
    dump[:elements] = *@elements
    return dump
  end

  def self._load(obj)
    Table.new(obj.unpack("VVVVVv*"))
  end
end

class Tone
  attr_accessor :red, :green, :blue, :gray

  def initialize(red, green, blue, gray = 0)
    @red, @green, @blue, @gray = red, green, blue, gray
  end

  def _dump
    dump = {
      red: @red,
      green: @green,
      blue: @blue,
      gray: @gray,
    }
  end

  def self._load(obj)
    Tone.new(*obj.unpack("EEEE"))
  end
end

module RPG
  class Event
    def _dump
      dump = {
        id: @id,
        name: @name.force_encoding("iso-8859-1").encode("utf-8"),
        x: @x,
        y: @y,
        pages: [],
      }
      for i in 0..(@pages.size - 1)
        dump[:pages] << @pages[i]._dump
      end
      return dump
    end

    class Page
      def _dump
        dump = {
          condition: "",
          graphic: "",
          move_type: @move_type,
          move_speed: @move_speed,
          move_frequency: @move_frequency,
          move_route: "",
          walk_anime: @walk_anime,
          step_anime: @step_anime,
          through: @through,
          always_on_top: @always_on_top,
          trigger: @trigger,
          list: [],
        }
        for i in 0..(@list.size - 1)
          dump[:list] << @list[i]._dump
        end
        dump[:condition] = @condition._dump
        dump[:graphic] = @graphic._dump
        dump[:move_route] = @move_route._dump
        return dump
      end

      class Condition
        def _dump
          dump = {
            switch1_valid: @switch1_valid,
            switch2_valid: @switch2_valid,
            variable_valid: @variable_valid,
            self_switch_valid: @self_switch_valid,
            switch1_id: @switch1_id,
            switch2_id: @switch2_id,
            variable_id: @variable_id,
            variable_value: @variable_value,
            self_switch_ch: @self_switch_ch,
          }
        end
      end

      class Graphic
        def _dump
          dump = {
            tile_id: @tile_id,
            character_name: @character_name,
            character_hue: @character_hue,
            direction: @direction,
            pattern: @pattern,
            opacity: @opacity,
            blend_type: @blend_type,
          }
        end
      end
    end
  end

  class EventCommand
    def _dump
      dump = { code: @code,
               indent: @indent,
               parameters: [] }
      for i in 0..(@parameters.length - 1)
        if @parameters[i].to_s.match(/#<RPG::/) || @parameters[i].to_s.match(/#<Tone:/) || @parameters[i].to_s.match(/#<Color:/) || @parameters[i].to_s.match(/#<Table:/)
          dump[:parameters] << @parameters[i]._dump
        elsif @parameters[i].is_a? String
          dump[:parameters] << @parameters[i].force_encoding("iso-8859-1").encode("utf-8")
        else
          dump[:parameters] << @parameters[i]
        end
      end
      dump
    end
  end

  class MoveRoute
    def _dump
      dump = {
        repeat: @repeat,
        skippable: @skippable,
        list: [],
      }
      for i in 0..(@list.length - 1)
        dump[:list] << @list[i]._dump
      end
      return dump
    end
  end

  class MoveCommand
    def _dump
      dump = {
        code: @code,
        parameters: @parameters,
      }
    end
  end

  class MapInfo
    attr_accessor :parent_id

    def _dump
      dump = {
        name: @name.force_encoding("iso-8859-1").encode("utf-8"),
        parent_id: @parent_id,
        order: @order,
        expanded: @expanded,
        scroll_x: @scroll_x,
        scroll_y: @scroll_y,
      }
    end
  end

  class AudioFile
    def _dump
      dump = {
        name: @name.force_encoding("iso-8859-1").encode("utf-8"),
        volume: @volume,
        pitch: @pitch,
      }
    end
  end
end

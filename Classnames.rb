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
    dump
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
      @pages.each_with_index do |value|
        dump[:pages] << value._dump
      end
      dump
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
        dump
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
      @parameters.each_with_index do |value|
        if value.to_s.match(/#<RPG::/) || value.to_s.match(/#<Tone:/) || value.to_s.match(/#<Color:/) || value.to_s.match(/#<Table:/)
          dump[:parameters] << value._dump
        elsif value.is_a? String
          dump[:parameters] << value.force_encoding("iso-8859-1").encode("utf-8")
        else
          dump[:parameters] << value
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
      @list.each_with_index do |value|
        dump[:list] << value._dump
      end
      dump
    end
  end

  class MoveCommand
    def _dump
      dump = {
        code: @code,
        parameters: [],
      }
      @parameters.each_with_index do |value|
        if value.to_s.match(/#<RPG::/) || value.to_s.match(/#<Tone:/) || value.to_s.match(/#<Color:/) || value.to_s.match(/#<Table:/)
          dump[:parameters] << value._dump
        elsif value.is_a? String
          dump[:parameters] << value.force_encoding("iso-8859-1").encode("utf-8")
        else
          dump[:parameters] << value
        end
      end
      dump
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

  class System
    class Words
      def _dump
        dump = {
          gold: @gold,
          hp: @hp,
          sp: @sp,
          str: @str,
          dex: @dex,
          agi: @agi,
          int: @int,
          atk: @atk,
          pdef: @pdef,
          mdef: @mdef,
          weapon: @weapon,
          armor1: @armor1,
          armor2: @armor2,
          armor3: @armor3,
          armor4: @armor4,
          attack: @attack,
          skill: @skill,
          gaurd: @gaurd,
          item: @item,
          equip: @equip,
        }
      end
    end

    class TestBattler
      def _dump
        dump = {
          actor_id: @actor_id,
          level: @level,
          weapon_id: @weapon_id,
          armor1_id: @armor1_id,
          armor2_id: @armor2_id,
          armor3_id: @armor3_id,
          armor4_id: @armor4_id,
        }
      end
    end
  end

  class CommonEvent
    def _dump
      dump = {
        id: @id,
        name: @name.force_encoding("iso-8859-1").encode("utf-8"),
        trigger: @trigger,
        switch_id: @switch_id,
        list: [],
      }
      @list.each_with_index do |value|
        dump[:list] << value._dump
      end
      dump
    end
  end

  class Tileset
    def _dump
      dump = {
        id: @id,
        name: @name,
        tileset_name: @tileset_name,
        autotile_names: @autotile_names,
        panorama_name: @panorama_name,
        panorama_hue: @panorama_hue,
        fog_name: @fog_name,
        fog_hue: @fog_hue,
        fog_opacity: @fog_opacity,
        fog_blend_type: @fog_blend_type,
        fog_zoom: @fog_zoom,
        fog_sx: @fog_sx,
        fog_sy: @fog_sy,
        battler_name: @battler_name,
        passages: @passages._dump,
        priorities: @priorities._dump,
        terrain_tags: @terrain_tags._dump,
      }
      dump
    end
  end

  class State
    def _dump
      dump = {
        id: @id,
        name: @name,
        animation_id: @animation_id,
        restriction: @restriction,
        nonresistance: @nonresistance,
        zero_hp: @zero_hp,
        cant_get_exp: @cant_get_exp,
        cant_evade: @cant_evade,
        slip_damage: @slip_damage,
        rating: @rating,
        hit_rate: @hit_rate,
        maxhp_rate: @maxhp_rate,
        maxsp_rate: @maxsp_rate,
        str_rate: @str_rate,
        dex_rate: @dex_rate,
        agi_rate: @agi_rate,
        int_rate: @int_rate,
        atk_rate: @atk_rate,
        pdef_rate: @pdef_rate,
        mdef_rate: @mdef_rate,
        eva: @eva,
        battle_only: @battle_only,
        hold_turn: @hold_turn,
        auto_release_prob: @auto_release_prob,
        shock_release_prob: @shock_release_prob,
        guard_element_set: @guard_element_set,
        plus_state_set: @plus_state_set,
        minus_state_set: @minus_state_set,
      }
    end
  end

  class Animation
    class Frame
      def _dump
        dump = {
          cell_max: @cell_max,
          cell_data: @cell_data._dump,
        }
      end
    end

    class Timing
      def _dump
        dump = {
          frame: @frame,
          se: @se._dump,
          flash_scope: @flash_scope,
          flash_color: @flash_color._dump,
          flash_duration: @flash_duration,
          condition: @condition,
        }
      end
    end

    def _dump
      dump = {
        id: @id,
        name: @name,
        animation_name: @animation_name,
        animation_hue: @animation_hue,
        position: @position,
        frame_max: @frame_max,
        frames: [],
        timings: [],
      }
      @frames.each_with_index do |value|
        dump[:frames] << value._dump
      end
      @timings.each_with_index do |value|
        dump[:timings] << value._dump
      end
      dump
    end
  end

  class Class
    class Learning
      def _dump
        dump = {
          level: @level,
          skill_id: @skill_id,
        }
      end
    end

    def _dump
      dump = {
        id: @id,
        name: @name,
        position: @position,
        weapon_set: @weapon_set,
        armor_set: @armor_set,
        element_ranks: @element_ranks._dump,
        state_ranks: @state_ranks._dump,
        learnings: [],
      }
      @learnings.each_with_index do |value|
        dump[:learnings] << value._dump
      end
      dump
    end
  end
end

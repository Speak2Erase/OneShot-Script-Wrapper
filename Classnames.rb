class Color
  attr_accessor :red, :green, :blue, :alpha

  def initialize(red, green, blue, alpha = 255)
    @red, @green, @blue, @alpha = red, green, blue, alpha
  end

  def _dump(limit)
    [@red, @green, @blue, @alpha].pack("EEEE")
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

  def _dump(limit)
    [@num_of_dimensions, @xsize, @ysize, @zsize, @num_of_elements, *@elements.flatten].pack("VVVVVv*")
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

  def _dump(limit)
    [@red, @green, @blue, @gray].pack("EEEE")
  end

  def self._load(obj)
    Tone.new(*obj.unpack("EEEE"))
  end
end

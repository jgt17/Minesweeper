# frozen_string_literal: true

require './position'

# dynamically created class to represent a single position
def custom_rectangular_position(width, height)
  Class.new(RectangularPosition) do
    @max_width = width
    @max_height = height
  end
end

# base position class for a rectangular minefield
# extended dynamically with the dimensions of the minefield
class RectangularPosition < Position
  include Utilities
  attr_reader :x_pos
  attr_reader :y_pos
  class << self
    attr_reader :max_width
    attr_reader :max_height
  end

  def initialize(x_pos, y_pos = nil)
    unless y_pos
      x_pos = x_pos % max_height
      y_pos = x_pos / max_height
    end
    @x_pos = x_pos
    @y_pos = y_pos

    super(y_pos * max_width + x_pos)
  end

  def to_s
    "(#{@x_pos}, #{@y_pos})"
  end

  def valid?
    return false unless check_integer_param @x_pos, :x_pos
    return false unless check_integer_param @y_pos, :y_pos
    return false unless @x_pos < max_width && @y_pos < max_height

    true
  end

  private

  def max_width
    self.class.max_width
  end

  def max_height
    self.class.max_height
  end
end

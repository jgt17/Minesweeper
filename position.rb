# frozen_string_literal: true

#
# a single position
class Position
  include Utilities
  attr_reader :x_pos
  attr_reader :y_pos

  def initialize(x_pos, y_pos, minefield = nil)
    raise Error "Position (#{@x_pos}, #{@y_pos}) is not in the minefield." unless minefield.nil? || valid?(minefield)

    @x_pos = x_pos
    @y_pos = y_pos
  end

  def to_s
    "(#{x_pos}, #{y_pos})"
  end

  private

  def valid?(minefield)
    return false unless check_integer_param @x_pos, :x_pos
    return false unless check_integer_param @y_pos, :y_pos
    return false unless minefield.is_a?(Minefield) && minefield.pos_in_range?(self)

    true
  end
end

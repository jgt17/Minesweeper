# frozen_string_literal: true
#
# a single position
class Position
  include Utilities
  attr_reader :x_pos
  attr_reader :y_pos

  def initialize(x_pos, y_pos, minefield = nil)
    return unless minefield.nil? || valid?(x_pos, y_pos, minefield)
    @x_pos = x_pos
    @y_pos = y_pos
  end

  def to_s
    "(#{x_pos}, #{y_pos})"
  end

  private

  def valid?(x_pos, y_pos, minefield)
    return false unless check_integer_param x_pos, :x_pos

    return false unless check_integer_param y_pos, :y_pos

    if minefield.is_a?(Minefield) && (x_pos >= minefield.width || y_pos >= minefield.height)
      raise_out_of_range_error(x_pos, y_pos, minefield.width, minefield.height)
    end
    true
  end
end

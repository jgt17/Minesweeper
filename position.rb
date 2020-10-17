# frozen_string_literal: true

# basic position
class Position
  attr_reader :true_position

  def initialize(index)
    @true_position = index
  end

  def ==(other)
    other.is_a?(Position) && @true_position == other.true_position
  end
end

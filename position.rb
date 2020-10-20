# frozen_string_literal: true

# basic position
# extended to map coordinates in different minefield topologies to the corresponding index in the underlying array
class Position
  attr_reader :true_position

  def initialize(index)
    @true_position = index
  end

  def ==(other)
    other.is_a?(Position) && @true_position == other.true_position
  end

  alias eql? ==
end

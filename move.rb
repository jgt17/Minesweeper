# frozen_string_literal: true

# for returning a full move specification, including which cell to modify and how to modify it
class Move
  attr_reader :cell

  def initialize(cell, flag)
    @cell = cell
    @flag = flag
  end

  def flag?
    @flag
  end

  def to_s
    @flag ? "Flag #{cell}" : "Reveal #{cell}"
  end

  def ==(other)
    other.is_a?(Move) && other.cell == @cell && other.flag? == @flag
  end

  alias eql? ==
end

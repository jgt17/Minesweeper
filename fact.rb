# frozen_string_literal: true

require './core_extensions'

# the individual nuggets of knowledge Nerd_Player reasons with
# can be combined under certain circumstances to infer new facts
class Fact
  attr_reader :cells
  attr_reader :mines_contained

  def initialize(cells = Set.new, mines_contained = 0)
    @cells = cells
    @mines_contained = mines_contained
  end

  # attempt to infer new facts by combining this fact with another one
  def infer(other)
    raise "expected a Fact, got #{other}" unless other&.is_a?(Fact)

    inferences = Set.new
    superset_inferences(other, inferences)
    intersection_forced_inferences(other, inferences)
    inferences
  end

  def certain?
    @mines_contained.zero? || @mines_contained == @cells.size
  end

  def safety
    @mines_contained.to_f / @cells.size
  end

  def ==(other)
    @cells == other.cells && @mines_contained == other.mines_contained
  end

  # remove a cell from the set
  def reveal_cell(cell)
    remove_cell(cell)
  end

  # flag a cell, removing it from the Fact and decrementing mines_contained if the cell was in the Fact
  def flag_cell(cell)
    decr_mines unless remove_cell(cell).nil?
  end

  # compare two facts with respect to which is a higher priority to process
  def compare_with(other)
    raise 'expected a fact' unless other&.is_a?(Fact)
    return other.certain? ? 0 : 1 if certain?

    other.certain? ? -1 : safety <=> other.safety
  end

  private

  # remove a cell from the fact, eg, when it is revealed or flagged
  def remove_cell(cell)
    @cells.delete?(cell)
  end

  # decrease mines in the cell by 1, eg, when a cell is flagged
  def decr_mines
    @mines_contained -= 1
  end

  # self is a strict superset
  def superset_inferences(other, inferences)
    inferences.safe_add(Fact.new(@cells ^ other.cells, @mines_contained - other.mines_contained)) if self > other
  end

  # other forces all cells in self not in other to be mines
  def intersection_forced_inferences(other, inferences)
    return unless @cells.intersect?(other.cells) && @mines_contained - other.mines_contained == (@cells - other.cells).size

    inferences.safe_add(Fact.new(@cells - other.cells, @mines_contained - other.mines_contained))
    inferences.safe_add(Fact.new(other.cells - @cells, 0))
    inferences.safe_add(Fact.new(other.cells & @cells, other.mines_contained))
  end
end

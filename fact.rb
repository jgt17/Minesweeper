# frozen_string_literal: true

require 'set'

# the individual nuggets of knowledge Nerd_Player reasons with
# can be combined under certain circumstances to infer new facts
class Fact
  attr_reader :cells
  attr_reader :mines_contained

  def initialize(cells = Set.new, mines_contained = 0)
    raise 'Expected a set' unless cells.is_a?(Set)
    raise 'More mines than cells' unless cells.size >= mines_contained
    raise 'Should be a set of cells' unless cells.all? { |n| n.is_a? Cell }

    @cells = cells
    @mines_contained = mines_contained
  end

  # attempt to infer new facts by combining this fact with another one
  # NOT commutative
  def infer(other)
    raise "expected a Fact, got #{other}" unless other&.is_a?(Fact)

    inferences = []
    return inferences if other.empty? || other == self # don't make inferences from empty or equivalent facts

    superset_inferences(other, inferences)
    intersection_forced_inferences(other, inferences)
    inferences
  end

  def certain?
    @mines_contained.zero? || @mines_contained == @cells.size
  end

  def safety
    1 - (@mines_contained.to_f / @cells.size)
  end

  def ==(other)
    @cells == other.cells && @mines_contained == other.mines_contained
  end

  alias eql? ==

  def hash
    k = 1
    @cells.each { |cell| k *= cell.hash }
    # noinspection RubyUnusedLocalVariable
    k += @mines_contained.hash
  end

  # remove a cell from the set
  def reveal_cell!(cell)
    remove_cell(cell)
  end

  # flag a cell, removing it from the Fact and decrementing mines_contained if the cell was in the Fact
  def flag_cell!(cell)
    decr_mines unless remove_cell(cell).nil?
  end

  # compare two facts with respect to which is a higher priority to process
  def compare_with(other)
    raise 'expected a fact' unless other&.is_a?(Fact)
    return other.certain? ? 0 : 1 if certain?

    other.certain? ? -1 : safety <=> other.safety
  end

  def empty?
    raise "Fact is empty but has #{@mines_contained} mines" unless @mines_contained.zero? || !@cells.empty?

    @cells.empty?
  end

  def to_s
    str = +'['
    @cells.each { |cell| str += "#{cell}, " }
    # noinspection RubyUnusedLocalVariable
    str += "Num mines: #{@mines_contained}]"
  end

  def random_cell
    @cells.to_a.sample
  end

  def size
    @cells.size
  end

  def include?(obj)
    @cells.include?(obj)
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
    inferences.append(Fact.new(@cells ^ other.cells, @mines_contained - other.mines_contained)) if @cells > other.cells
  end

  # other forces all cells in self not in other to be mines
  def intersection_forced_inferences(other, inferences)
    return unless intersect_but_no_superset(other) && size_diff_matches_mine_diff(other)

    inferences.append(Fact.new(@cells - other.cells, @mines_contained - other.mines_contained),
                      Fact.new(other.cells - @cells, 0),
                      Fact.new(other.cells & @cells, other.mines_contained))
  end

  def intersect_but_no_superset(other)
    @cells.intersect?(other.cells) && !(other.cells > @cells || @cells > other.cells)
  end

  def size_diff_matches_mine_diff(other)
    @mines_contained - other.mines_contained == (@cells - other.cells).size
  end
end

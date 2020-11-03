# frozen_string_literal: true

# rubocop:disable Metrics/AbcSize, Metrics/MethodLength, Metrics/ClassLength

require 'minitest/autorun'
require './fact'

class FactTest < Minitest::Test
  def test_initialize
    fact = Fact.new
    assert fact.cells == Set.new && fact.mines_contained == 0
    cells = Set.new([Cell.new, Cell.new])
    fact = Fact.new(cells, 2)
    assert fact.cells == cells && fact.mines_contained == 2
    assert_raises 'More mines than cells' do
      Fact.new(cells, 3)
    end
    cells.add 5
    assert_raises 'Should be a set of cells' do
      Fact.new(cells, 3)
    end
    assert_raises 'Expected a set' do
      Fact.new(5, 1)
    end
  end

  def test_infer
    cell1 = Cell.new
    cell2 = Cell.new
    cell3 = Cell.new
    cell4 = Cell.new
    fact1 = Fact.new(Set.new([cell1, cell2, cell3]), 2)
    fact2 = Fact.new(Set.new([cell1, cell2]), 1)
    assert fact1.infer(fact2) == [Fact.new(Set.new([cell3]), 1)]
    fact3 = Fact.new(Set.new([cell2, cell3, cell4]), 1)
    assert fact1.infer(fact3) == [Fact.new(Set.new([cell1]), 1),
                                  Fact.new(Set.new([cell4]), 0),
                                  Fact.new(Set.new([cell2, cell3]), 1)]
    assert fact1.infer(Fact.new) == []
    assert fact1.infer(fact1) == []
    assert fact1.infer(Fact.new(Set.new([cell2, cell3, cell4, Cell.new]), 2)) == []
    assert_raises do
      fact1.infer 5
    end
  end

  def test_certain
    cells = Set.new([Cell.new, Cell.new])
    refute Fact.new(cells, 1).certain?
    assert Fact.new(cells, 2).certain?
    assert Fact.new(cells, 0).certain?
  end

  def test_safety
    cells = Set.new([Cell.new, Cell.new])
    assert Fact.new(cells, 0).safety == 1
    assert Fact.new(cells, 1).safety == 0.5
    assert Fact.new(cells, 2).safety == 0
  end

  def test_eql
    cell1 = Cell.new
    cell2 = Cell.new
    fact1 = Fact.new(Set.new([cell1, cell2]), 1)
    fact2 = Fact.new(Set.new([cell2, cell1]), 1)
    assert fact1 == fact2
    fact3 = Fact.new(Set.new([cell1, cell2, Cell.new]), 1)
    refute fact1 == fact3
    fact4 = Fact.new(Set.new([cell1, cell2]), 2)
    refute fact1 == fact4
  end

  def test_set_uniqueness
    cell1 = Cell.new
    cell2 = Cell.new
    fact1 = Fact.new(Set.new([cell1, cell2]), 1)
    fact2 = Fact.new(Set.new([cell2, cell1]), 1)
    fact3 = Fact.new(Set.new([cell1, cell2, Cell.new]), 1)
    fact4 = Fact.new(Set.new([cell2]), 1)
    set = Set.new
    assert set.add?(fact1)
    refute set.add?(fact2)
    assert set.add?(fact3)
    fact1.reveal_cell(cell1)
    refute set.add?(fact4)
  end

  def test_reveal_cell
    cell1 = Cell.new
    cell2 = Cell.new
    set = Set.new([cell1, cell2])
    fact = Fact.new(set, 0)
    fact.reveal_cell(cell1)
    refute set.include? cell1
    fact.reveal_cell(Cell.new)
    assert set == Set.new([cell2])
  end

  def test_flag_cell
    cell1 = Cell.new
    cell2 = Cell.new
    set = Set.new([cell1, cell2])
    fact = Fact.new(set, 2)
    fact.flag_cell(cell1)
    refute set.include? cell1
    assert fact.mines_contained == 1
    fact.reveal_cell(Cell.new)
    assert set == Set.new([cell2])
    assert fact.mines_contained == 1
  end

  def test_compare_with
    fact1 = Fact.new(Set.new([Cell.new, Cell.new, Cell.new]), 0)
    fact2 = Fact.new(Set.new([Cell.new, Cell.new, Cell.new]), 3)
    fact3 = Fact.new(Set.new([Cell.new, Cell.new, Cell.new]), 2)
    fact4 = Fact.new(Set.new([Cell.new, Cell.new, Cell.new]), 1)
    assert fact1.compare_with(fact2) == 0
    assert fact1.compare_with(fact3) == 1
    assert fact2.compare_with(fact1) == 0
    assert fact2.compare_with(fact3) == 1
    assert fact3.compare_with(fact1) == -1
    assert fact3.compare_with(fact2) == -1
    assert fact3.compare_with(fact4) == -1
    assert fact4.compare_with(fact3) == 1
    assert fact4.compare_with(fact4) == 0
    assert_raises 'expected a fact' do
      fact4.compare_with(5)
    end
  end

  def test_empty
    refute Fact.new(Set.new([Cell.new, Cell.new, Cell.new]), 0).empty?
    assert Fact.new(Set.new([]), 0)
    assert_raises do
      Fact.new(Set.new([]), 1)
    end
  end
end
# rubocop:enable Metrics/AbcSize, Metrics/MethodLength, Metrics/ClassLength

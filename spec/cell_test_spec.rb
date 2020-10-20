# frozen_string_literal: true

# rubocop:disable Metrics/AbcSize, Metrics/MethodLength

require 'minitest/autorun'
require './cell'

class CellTest < Minitest::Test
  def test_initialize
    cell = Cell.new
    assert !cell.nil?
    assert cell.revealed? == false
    assert cell.flagged? == false
    assert(cell.neighbors.is_a?(Set) && cell.neighbors.empty?)
  end

  def test_add_neighbor
    cell1 = Cell.new
    cell2 = Cell.new
    assert cell1.neighbors.empty?
    cell1.add_neighbor(cell2)
    assert cell1.neighbors.include?(cell2)
    cell1.add_neighbor(cell2)
    assert cell1.neighbors.length == 1
    assert_raises 'Expected a cell' do 
      cell1.add_neighbor(5)
    end
    assert_raises 'A cell cannot neighbor itself' do
      cell1.add_neighbor(cell1)
    end
  end

  def test_neighbors?
    cell1 = Cell.new
    cell2 = Cell.new
    refute cell1.neighbors?(cell2)
    cell1.add_neighbor(cell2)
    assert cell1.neighbors?(cell2)
    cell1.reveal
    assert cell1.num_neighboring_mines == 0
    cell1.add_neighbor(Cell.new(true))
    assert cell1.num_neighboring_mines == 1
  end

  def test_num_neighboring_mines
    cell1 = Cell.new
    cell2 = Cell.new
    cell3 = Cell.new true
    cell1.add_neighbor(cell2)
    assert cell1.num_neighboring_mines.nil?
    cell1.reveal
    assert cell1.num_neighboring_mines == 0
    cell1.add_neighbor(cell3)
    assert cell1.num_neighboring_mines == 1
  end

  def test_to_s
    cell1 = Cell.new
    assert cell1.to_s == '□'
    cell1.flag
    assert cell1.to_s == '▣'
    cell1.unflag
    cell1.reveal
    assert cell1.to_s == '.'
    cell1.add_neighbor(Cell.new(true))
    assert cell1.to_s == '1'
    cell1.set_mine
    assert cell1.to_s == '◈'
  end

  def test_reveal
    cell1 = Cell.new
    refute cell1.revealed?
    cell1.flag
    refute cell1.reveal
    refute cell1.revealed?
    cell1.unflag
    assert cell1.reveal == 0
    assert cell1.revealed?
    refute cell1.reveal
  end

  def test_flag_and_unflag
    cell1 = Cell.new
    refute cell1.flagged?
    cell1.flag
    assert cell1.flagged?
    refute cell1.flag
    cell1.unflag
    refute cell1.flagged?
    refute cell1.unflag
    cell1.reveal
    assert cell1.flag.nil?
  end

  def test_set_mine
    cell1 = Cell.new
    cell2 = Cell.new
    cell1.add_neighbor(cell2)
    cell2.reveal
    assert cell2.num_neighboring_mines == 0
    assert cell1.set_mine
    assert cell2.num_neighboring_mines == 1
    refute cell1.set_mine
  end

  def test_neighbor_selection
    cell1 = Cell.new
    cell2 = Cell.new
    cell3 = Cell.new
    cell3.flag
    cell4 = Cell.new
    cell4.reveal
    cell1.add_neighbor(cell2)
    cell1.add_neighbor(cell3)
    cell1.add_neighbor(cell4)
    assert cell1.hidden_and_unflagged_neighbors == Set.new([cell2])
    assert cell1.flagged_neighbors == Set.new([cell3])
  end
end
# rubocop:enable Metrics/AbcSize, Metrics/MethodLength

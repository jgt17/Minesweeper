# frozen_string_literal: true

require 'set'

# class representing an individual cell of the minefield
class Cell
  attr_reader :neighbors
  attr_reader :position

  def initialize(is_mine = false)
    @revealed = false
    @flagged = false
    @is_mine = is_mine
    @neighbors = Set.new
    @num_neighbor_mines = 0
  end

  # add a neighboring cell
  def add_neighbor(other_cell)
    raise 'Expected a cell' unless other_cell.is_a?(Cell)
    raise 'A cell cannot neighbor itself' if other_cell == self

    @neighbors << other_cell
    incr_neighbor_mines if other_cell.mine?
  end

  # check if this cell and the other cell are neighbors
  def neighbors?(other_cell)
    @neighbors.include?(other_cell)
  end

  # attempt to access the number of mines neighboring this cell
  def num_neighboring_mines
    @revealed ? @num_neighbor_mines : nil
  end

  # string representation for displaying the minefield in the console
  def to_s
    return '▣' if @flagged
    return '□' unless @revealed # an empty box
    return '◈' if @is_mine # an explosion symbol

    @num_neighbor_mines.zero? ? '.' : @num_neighbor_mines.to_s
  end

  # reveal the contents of a cell
  def reveal
    return false if @flagged || @revealed

    @revealed = true
    @is_mine ? nil : @num_neighbor_mines
  end

  # flag the cell, returns true if the cell was not already flagged
  def flag
    @flagged != @flagged = true unless @revealed
  end

  # unflag the cell, returns true if the cell was not already unflagged
  def unflag
    @flagged != @flagged = false
  end

  # set a cell to be a mine
  def set_mine
    return false if @is_mine

    # rubocop:disable Style/SymbolProc
    @neighbors.each { |n| n.incr_neighbor_mines }
    # @neighbors.each(&:incr_neighbor_mines) raises a method not found error
    # rubocop:enable Style/SymbolProc
    @is_mine = true
  end

  # check if a cell has been flagged
  def flagged?
    @flagged
  end

  # check if a cell has been revealed
  def revealed?
    @revealed
  end

  def hidden_and_unflagged_neighbors
    Set.new(@neighbors.select { |n| !n.revealed? && !n.flagged? })
  end

  def flagged_neighbors
    Set.new(@neighbors.select(&:flagged?))
  end

  protected

  def mine?
    @is_mine
  end

  def incr_neighbor_mines
    @num_neighbor_mines += 1
  end
end

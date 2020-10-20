# frozen_string_literal: true

require 'set'

# class representing an individual cell of the minefield
class Cell
  attr_reader :is_mine
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
    puts other_cell.nil?
    raise 'Expected a cell' unless other_cell.is_a?(Cell)

    puts 'adding neighbor'
    @neighbors << other_cell
  end

  # check if this cell and the other cell are neighbors
  def neighbors?(other_cell)
    @neighbors.include?(other_cell)
  end

  # attempt to access the number of mines neighboring this cell
  def num_neighboring_mines
    @revealed ? @num_neighbor_mines : nil
  end

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

    @neighbors.each(&:incr_neighbor_mines)
    @is_mine = true
  end

  def flagged?
    @flagged
  end

  def revealed?
    @revealed
  end

  def incr_neighbor_mines
    @num_neighbor_mines += 1
  end

  def hidden_and_unflagged_neighbors
    puts 'neighbors'
    puts(@neighbors.select { |n| !n.revealed? && !n.flagged? })
    Set.new(@neighbors.select { |n| !n.revealed? && !n.flagged? })
  end

  def flagged_neighbors
    Set.new(@neighbors.select(&:flagged?))
  end
end

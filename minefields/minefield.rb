# frozen_string_literal: true

require 'set'
require './cell'
require './display'

# basic minefield, no neighbor topology
# allows expanding to rectangular and other configurations (hex, triangles)
# without player's needing to know precise details
class Minefield
  include Displays
  attr_reader :first_click
  attr_reader :num_mines
  attr_reader :num_flagged
  attr_reader :num_cells
  attr_accessor :player
  MAX_MINE_DENSITY = 0.5

  def initialize(num_cells, num_mines, first_click = nil)
    @minefield = Array.new(num_cells) { Cell.new }
    @num_mines = num_mines
    @num_cells = num_cells
    @first_click = first_click || random_position
    @num_to_clear = num_cells - num_mines
    @num_flagged = 0
    @player = nil
    generate
  end

  # get a random cell in the minefield
  def random_position
    position_class.new(rand(@num_cells))
  end

  def to_s
    @minefield.to_s
  end

  # get the subclass of Position used for this minefield
  def position_class
    @position_class || Position
  end

  # 'click' a hidden cell
  def reveal(cell)
    return DISPLAY.call('Attempted to reveal cell not in minefield') && false unless include?(cell)

    neighbor_mine_count = cell.reveal
    return trip_mine if neighbor_mine_count.nil?

    # don't update revealed data if the cell was not successfully revealed
    # ie, if the cell was flagged or had already been revealed
    return if neighbor_mine_count == false

    @num_to_clear -= 1
    @player&.notify_revealed(cell)
    cascade_reveal(cell) if neighbor_mine_count.zero?
  end

  # flag the indicated cell
  def flag(cell)
    return DISPLAY.call('Attempted to flag cell not in minefield') && false unless include?(cell)

    @num_flagged += 1 if cell.flag
  end

  # unflag the indicated cell
  def unflag(cell)
    return DISPLAY.call('Attempted to unflag cell not in minefield') && false unless include?(cell)

    @num_flagged -= 1 if cell.unflag
  end

  # check if the minefield has been successfully cleared yet
  def clear?
    @num_to_clear.zero?
  end

  # get the cell at position
  def cell_at(position)
    @minefield[position.true_position]
  end

  def position_of(cell)
    position_class.new(@minefield.index(cell))
  end

  def all_cells
    all = Set.new
    @minefield.each { |cell| all.add(cell)}
    all
  end

  def hidden_and_unflagged_cells
    Set.new(@minefield.reject { |cell| cell.revealed? || cell.flagged? } )
  end

  private

  # populate the minefield
  def generate
    assign_neighbors
    populate_trapped_cells
  end

  # lay mines
  def populate_trapped_cells
    mines_laid = 0
    until mines_laid == @num_mines
      pos = random_position
      mines_laid += 1 if pos != @first_click && !cell_at(pos).neighbors?(cell_at(@first_click)) && cell_at(pos).set_mine
    end
  end

  # tell each cell who its neighbors are
  # overwritten for each different type of minefield
  def assign_neighbors
    (0...@num_cells - 1).each do |i|
      @minefield[i].add_neighbor(@minefield[i + 1])
      @minefield[i + 1].add_neighbor(@minefield[i])
    end
  end

  # check that there aren't too many mines
  def validate_mine_density
    error_string = "Too many mines! #{@num_mines} specified, but the minefield has an area of #{@minefield.length}."
    raise error_string unless @num_mines < @num_cells * MAX_MINE_DENSITY
  end

  # check that first_click is a position in the minefield
  def validate_first_click
    raise 'first_click must be a position if provided!' unless @first_click.nil? || @first_click.is_a?(Position)
    raise pos_out_of_range(@first_click) unless include?(@first_click)
  end

  # raise an error if a given position is not valid for the minefield
  def pos_out_of_range(position)
    Error "Position out of range! (#{position.true_position}) given, " \
          "but the minefield is #{@num_cells} long."
  end

  # check the minefield params for general errors
  def validate_params
    validate_mine_density
    validate_first_click
  end

  # check if a cell or position is in the minefield
  def include?(cell_or_position)
    (cell_or_position.is_a?(Cell) && @minefield.include?(cell_or_position)) ||
      (cell_or_position.is_a?(Position) && cell_or_position.true_position < @num_cells)
  end

  # kaboom
  def trip_mine
    DISPLAY.call 'Revealed a Mine!'
    DISPLAY.call self
    raise 'Revealed a Mine!'
  end

  # continue revealing cells as long as they have no neighboring mines
  def cascade_reveal(cell)
    cell.neighbors.each do |n|
      reveal(n) unless n.revealed?
    end
  end
end

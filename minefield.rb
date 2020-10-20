# frozen_string_literal: true

require 'set'
require './cell'

# basic minefield, no neighbor topology
# allows expanding to rectangular and other configurations (hex, triangles)
# without player's needing to know precise details
class Minefield
  attr_reader :first_click
  attr_reader :num_mines
  attr_reader :num_flagged
  attr_reader :num_cells
  attr_accessor :player
  MAX_MINE_DENSITY = 0.5

  def initialize(num_cells, num_mines, first_click = nil)
    @minefield = Array.new(num_cells) { Cell.new }
    @num_mines = num_mines
    @first_click = first_click || random_position
    @num_to_clear = num_cells - num_mines
    @num_flagged = 0
    @num_cells = num_cells
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
    return puts('Attempted to reveal cell not in minefield') && false unless include?(cell)

    neighbor_mine_count = cell.reveal
    trip_mine if neighbor_mine_count.nil?

    # don't update revealed data if the cell was not successfully revealed
    # ie, if the cell was flagged or had already been revealed
    puts neighbor_mine_count
    return if neighbor_mine_count == false

    @num_to_clear -= 1
    @player&.notify_revealed(cell)
    cascade_reveal(cell) if neighbor_mine_count.zero?
  end

  # flag the indicated cell
  def flag(cell)
    return puts('Attempted to reveal cell not in minefield') && false unless include?(cell)

    @num_flagged += 1 if cell.flag
  end

  # unflag the indicated cell
  def unflag(cell)
    return puts('Attempted to reveal cell not in minefield') && false unless include?(cell)

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
    puts 'grabbing all cells'
    all = Set.new
    @minefield.each { |cell| all.add(cell); puts 'adding cell' }
    puts 'done'
    all
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
      puts 'laying mine'
      pos = position_class.new(rand(@num_cells))
      puts pos
      puts pos.true_position
      puts cell_at(pos).nil?
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
    puts 'Revealed a Mine!'
    puts self
    exit 5
  end

  # continue revealing cells as long as they have no neighboring mines
  def cascade_reveal(cell)
    puts 'cascade revealing'
    cell.neighbors.each do |n|
      puts "revealing #{n}" unless n.revealed?
      reveal(n) unless n.revealed?
    end
  end
end

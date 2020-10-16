# frozen_string_literal: true

require './cell'

# basic minefield, no neighbor topology
class Minefield
  attr_reader :first_click
  attr_reader :num_mines
  attr_reader :num_flagged
  attr_reader :num_cells
  MAX_MINE_DENSITY = 0.5

  def initialize(num_cells, num_mines, first_click = nil)
    @minefield = Array.new(num_cells) { Cell.new }
    @num_mines = num_mines
    @first_click = first_click || random_position
    @num_to_clear = num_cells - num_mines
    @num_flagged = 0
    @num_cells = num_cells
    generate
  end

  def random_position
    (@position_class || Position).new(rand(@minefield.length))
  end

  def to_s
    @minefield.to_s
  end

  # get the subclass of Position used for this minefield
  def position_class
    @position_class || Position
  end

  def reveal(cell)
    check_cell_in_minefield(cell)
    neighbor_mine_count = cell.reveal
    trip_mine if neighbor_mine_count.nil?

    # don't decrement num_to_clear if the cell was not successfully revealed
    # ie, if the cell was flagged or had already been revealed
    @num_to_clear -= 1 if neighbor_mine_count
    neighbor_mine_count
  end

  # flag the indicated cell
  def flag(cell)
    check_cell_in_minefield(cell)
    @num_flagged += 1 if cell.flag
  end

  # unflag the indicated cell
  def unflag(cell)
    check_cell_in_minefield(cell)
    @num_flagged -= 1 if cell.unflag
  end

  # check if the minefield has been successfully cleared yet
  def clear?
    @num_to_clear.zero?
  end

  def cell_at(position)
    @minefield[position.true_position]
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
      pos = rand(@minefield.length)
      unless @minefield[pos].neighbors?(@first_click)
        @minefield[pos].set_mine
        mines_laid += 1
      end
    end
  end

  # tell each cell who its neighbors are
  # overwritten for each different type of minefield
  def assign_neighbors
    (0...@minefield.length - 1).each do |i|
      @minefield[i].add_neighbor(@minefield[i + 1])
      @minefield[i + 1].add_neighbor(@minefield[i])
    end
  end

  # check that there aren't too many mines
  def validate_mine_density
    error_string = "Too many mines! #{@num_mines} specified, but the minefield has an area of #{@minefield.length}."
    raise Error error_string unless @num_mines < @minefield.length * MAX_MINE_DENSITY
  end

  # check that first_click is a position in the minefield
  def validate_first_click
    raise Error 'first_click must be a position if provided!' unless @first_click.nil? || @first_click.is_a?(Position)
    raise pos_out_of_range(@first_click) unless pos_in_range?(@first_click)
  end

  def pos_in_range?(position)
    raise Error 'Expected position.' unless position.is_a? Position

    position.true_position < @minefield.length
  end

  # raise an error if a given position is not valid for the minefield
  def pos_out_of_range(position)
    Error "Position out of range! (#{position.true_position}) given, " \
          "but the minefield is #{@minefield.length} long."
  end

  # check the minefield params for general errors
  def validate_params
    validate_mine_density
    validate_first_click
  end

  def check_cell_in_minefield(cell)
    raise 'Expected a cell in the minefield' unless cell.is_a?(Cell) && @minefield.include?(cell)
  end

  def trip_mine
    puts 'Revealed a Mine!'
    puts self
    exit 5
  end

  def cascade_reveal
    #TODO
  end
end

require './cell'

# basic minefield, no neighbor topology
class Minefield
  attr_reader :first_click
  attr_reader :num_mines
  MAX_MINE_DENSITY = 0.5

  def initialize(num_cells, num_mines, first_click = nil)
    @minefield = Array.new(num_cells) { Cell.new }
    @num_mines = num_mines
    @first_click = first_click || random_position
    generate
  end

  def random_position
    Position.new(rand(@minefield.length))
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

  def cell_at(position)
    @minefield[position.true_position]
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
    Error "RectangularPosition out of range! (#{position.true_position}) given, " \
          "but the minefield is #{@minefield.length} long."
  end

  # check the minefield params for general errors
  def validate_params
    validate_mine_density
    validate_first_click
  end
end

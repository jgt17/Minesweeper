# frozen_string_literal: true

require './utilities'

# The minefield
class Minefield
  include Utilities
  attr_reader :width
  attr_reader :height
  attr_reader :first_click
  MAX_MINE_DENSITY = 0.75

  def initialize(width = 30, height = 16, num_mines = 99, first_click = nil)
    # default to expert, random first click
    @width = width
    @height = height
    @num_mines = num_mines
    @first_click = first_click || random_position
    check_params
    @minefield = Array.new(width) { Array.new(height) }
    generate
  end

  def random_position
    Position.new rand(@width), rand(@height)
  end

  def to_s
    str = ''
    @minefield.each do |row|
      row.each { |cell| str += cell + ' ' }
      str.delete_suffix!(' ')
      str += '\n'
    end
    str.delete_suffix('\n')
  end

  def pos_in_range?(position)
    raise Error 'Expected position.' unless position.is_a? Position

    position.x_pos >= @width || position.y_pos >= @height
  end

  # raise an error if a given position is not valid for the minefield
  def pos_out_of_range(position)
    Error "Position out of range! (#{position.x_pos}, #{position.y_pos}) given, " \
          "but the minefield is #{@width} by #{@height}."
  end

  private

  # check that the params of the minefield are within accepted values
  def check_params
    check_integer_param @width, :width
    check_integer_param @height, :height
    check_integer_param @num_mines, :num_mines
    validate_params
    true
  end

  # check the minefield params for general errors
  def validate_params
    validate_mine_density
    validate_first_click
  end

  # check that there aren't too many mines
  def validate_mine_density
    error_string = "Too many mines! #{@num_mines} specified, but the minefield has an area of #{@width * @height}."
    raise Error error_string unless @num_mines < (@width * @height) * MAX_MINE_DENSITY
  end

  # check that first_click is a position in the minefield
  def validate_first_click
    raise Error 'first_click must be a position if provided!' unless @first_click.nil? || @first_click.is_a?(Position)
    raise pos_out_of_range(@first_click) unless pos_in_range?(@first_click)
  end

  # create the minefield
  def generate
    populate_trapped_cells
    populate_empty_cells
    assign_neighbors
  end

  # lay mines
  def populate_trapped_cells
    mines_laid = 0
    forbidden_x_values, forbidden_y_values = neighboring_ranges(@first_click.x_pos, @width, @first_click.y_pos, @height)
    until mines_laid == @num_mines
      x_pos = rand(@width)
      y_pos = rand(@height)
      unless forbidden_x_values.member?(x_pos) && forbidden_y_values.member?(y_pos)
        @minefield[x_pos][y_pos] = Cell.new(Position.new(x, y), true)
        mines_laid += 1
      end
    end
  end

  # generate cells with no mines
  def populate_empty_cells
    (0...@width).each do |x|
      (0...@height).each do |y|
        @minefield[x][y] ||= Cell.new(Position.new(x, y))
      end
    end
  end

  # tell each cell who it's neighbors are
  def assign_neighbors
    (0...@width).each do |x|
      (0...@height).each do |y|
        raise Error "#{@minefield[x][y]} is not a cell." unless @minefield[x][y].is_a? Cell

        @minefield[x][y].neighbors = gather_neighbors(x, y)
      end
    end
  end

  # returns an array of cells that neighbor the cell at (x, y)
  def gather_neighbors(x_pos, y_pos)
    neighbors = []
    x_neighbors, y_neighbors = neighboring_ranges(x_pos, y_pos, @width, @height)
    x_neighbors.each do |i|
      y_neighbors.each do |j|
        neighbors << @minefield[i][j] unless i == x_pos && j == y_pos
      end
    end
  end
end

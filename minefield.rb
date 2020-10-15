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
    check_params(width, height, num_mines, first_click)
    @minefield = Array.new(width) { Array.new(height) }
    @width = width
    @height = height
    @num_mines = num_mines
    @first_click ||= random_position
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

  private

  def check_params(width, height, num_mines, first_click)
    check_integer_param width, :width
    check_integer_param height, :height
    check_integer_param num_mines, :num_mines
    check_for_errors(width, height, num_mines, first_click)
    true
  end

  # check the minefield params for general errors
  def check_for_errors(width, height, num_mines, first_click)
    error_string = "Too many mines! #{num_mines} specified, but the minefield has an area of #{width * height}."
    raise Error error_string unless num_mines < (width * height) * MAX_MINE_DENSITY
    raise Error 'first_click must be a position if provided!' unless first_click.nil? || first_click.is_a?(Position)

    # noinspection RubyNilAnalysis
    in_range = first_click.x_pos < width && first_click.y_pos < height
    raise_out_of_range_error(first_click.x_pos, first_click.y_pos, width, height) unless first_click.nil? || in_range
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

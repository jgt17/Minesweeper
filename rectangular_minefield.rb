# frozen_string_literal: true

require './utilities'
require './rectangular_position'
require './minefield'

# The traditional minefield
class RectangularMinefield < Minefield
  include Utilities
  attr_reader :width
  attr_reader :height
  MAX_MINE_DENSITY = 0.75

  def initialize(width = 30, height = 16, num_mines = 99, first_click = nil)
    # default to expert, random first click
    @width = width
    @height = height
    @position_class = custom_rectangular_position(@width, @height) # create position class for this minefield
    super(width * height, num_mines, first_click)
    check_params
  end

  def to_s
    str = +''
    (0...@height).each do |y|
      (0...@width).each do |x|
        str << cell_at(@position_class.new(x, y)).to_s << '     '
      end
      str.delete_suffix!('     ')
      str << "\n"
    end
    str.delete_suffix("\n")
  end

  # raise an error if a given position is not valid for the minefield
  def pos_out_of_range(position)
    Error "RectangularPosition out of range! (#{position.x_pos}, #{position.y_pos}) given, " \
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

  # tell each cell who its neighbors are
  def assign_neighbors
    (0...@width).each do |x|
      (0...@height).each do |y|
        gather_neighbors(x, y)
      end
    end
  end

  # returns an array of cells that neighbor the cell at (x, y)
  def gather_neighbors(x_pos, y_pos)
    cell = cell_at(@position_class.new(x_pos, y_pos))
    x_neighbors, y_neighbors = neighboring_ranges(x_pos, y_pos, @width, @height)
    x_neighbors.each do |i|
      y_neighbors.each do |j|
        pos = @position_class.new(i, j)
        cell.add_neighbor(cell_at(pos)) unless !pos.nil? || (i == x_pos && j == y_pos)
      end
    end
  end
end

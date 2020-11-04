# frozen_string_literal: true

require './validation_utilities'

# collection of methods for verifying that minefields being instantiated are valid configurations
module MinefieldValidationUtilities
  # the maximum number of cells a minefield may have
  MAX_SIZE = 2046
  # the maximum allowed ratio of total cells to mines
  MAX_MINE_DENSITY = 0.5

  include ValidationUtilities

  # check the minefield params for general errors
  # subclasses of Minefield should implement type_specific_checks appropriately
  def validate_params
    validate_size
    validate_mine_density
    validate_first_click
    type_specific_checks
  end

  # check that there aren't too many cells
  def validate_size
    @num_mines <= MAX_SIZE
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
    Error "Position out of range! (#{position}) given, " \
          "but the minefield is #{@num_cells} long."
  end
end

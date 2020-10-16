# frozen_string_literal: true

require './minefield'
require './cell'

# general player
class Player
  def initialize(minefield)
    raise 'Expected a minefield' unless minefield.is_a? Minefield

    @minefield = minefield
    @position_type = minefield.position_class
  end

  def reveal(cell)
    @minefield.reveal(cell) unless cell.flagged?
  end

  def flag(cell)
    @minefield.flag(cell)
  end

  def unflag(cell)
    @minefield.unflag(cell)
  end

  def play
    puts @minefield.clear?
    reveal @minefield.cell_at(@minefield.first_click)
    make_move until @minefield.clear?
  end

  def make_move
    raise 'No strategy defined.'
  end
end

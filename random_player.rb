# frozen_string_literal: true

require './player'
require 'set'

# a player that guesses randomly and un-intelligently
class RandomPlayer < Player
  def initialize(minefield)
    super
    @unrevealed_cells = minefield.all_cells
  end

  def make_move
    puts @minefield
    cell = @unrevealed_cells.sample
    puts "Guessing #{@minefield.position_of(cell)} is safe."
    reveal(cell)
  end

  def notify_revealed(cell)
    puts 'test'
    @unrevealed_cells.delete(cell)
  end
end

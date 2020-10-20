# frozen_string_literal: true

require './player'
require 'set'

# a player that guesses randomly and un-intelligently
class RandomPlayer < Player
  def initialize
    super
    @unrevealed_cells = []
  end

  def notify_revealed(cell)
    @unrevealed_cells.delete(cell)
  end

  def choose_move
    puts @minefield
    cell = @unrevealed_cells.sample
    puts "Guessing #{@minefield.position_of(cell)} is safe."
    Move.new(cell, false)
  end

  def setup(minefield)
    super(minefield)
    @unrevealed_cells = minefield.all_cells
  end

  def clean_up
    super
    @unrevealed_cells = []
  end
end

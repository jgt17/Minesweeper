# frozen_string_literal: true

require_relative './player'
require 'set'
require_relative '../display'

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
    DISPLAY.call @minefield
    cell = @unrevealed_cells.sample
    DISPLAY.call "Guessing #{@minefield.position_of(cell)} is safe."
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

# frozen_string_literal: true

require './player'

# a player that guesses randomly and un-intelligently
class RandomPlayer < Player
  def make_move
    puts @minefield
    position = @minefield.random_position
    puts "Guessing #{position} is safe."
    reveal(@minefield.cell_at(position))
  end
end

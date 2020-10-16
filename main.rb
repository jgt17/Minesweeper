# frozen_string_literal: true

require './rectangular_minefield'
require './random_player'

minefield = RectangularMinefield.new(10, 10, 3)
puts minefield
randy = RandomPlayer.new(minefield)

randy.play


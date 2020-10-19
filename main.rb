# frozen_string_literal: true

require './rectangular_minefield'
require './random_player'
require './nerd_player'
require 'set'

minefield = RectangularMinefield.new(10, 10, 3)
puts minefield
sheldon = NerdPlayer.new
sheldon.play(minefield)


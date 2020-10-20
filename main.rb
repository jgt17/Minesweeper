# frozen_string_literal: true

require './rectangular_minefield'
require './random_player'
require './nerd_player'
# require './display'
require 'set'

include Displays

minefield = RectangularMinefield.new(16, 16, 40)
puts DISPLAY
DISPLAY.call minefield
sheldon = NerdPlayer.new
sheldon.play(minefield)


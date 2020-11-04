# frozen_string_literal: true

require './minefields/rectangular_minefield'
require './players/random_player'
require './players/nerd_player'
require './players/geek_player'
# require './display'
require 'set'

# main class
class Main
  def self.play(minefield = RectangularMinefield.new, player = GeekPlayer.new)
    include Displays

    DISPLAY.call minefield
    player.play(minefield)
  end

  def self.benchmark(width, height, mines, runs, player = GeekPlayer.new)
    games_won = 0
    runs.times do |i|
      puts i if (i % (runs / 100)).zero?
      minefield = RectangularMinefield.new(width, height, mines)
      games_won += 1 if player.play(minefield)
    end
    puts games_won.to_f / runs
  end
end

# Todo generalize benchmark to different minefield types (implement generating minefield from other)
Main.benchmark(9, 9, 10, 100)
# Main.play

# todo refactor code and make it pretty
# todo support non-random first guesses

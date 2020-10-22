# frozen_string_literal: true

require './minefields/rectangular_minefield'
require './players/random_player'
require './players/nerd_player'
require './players/geek_player'
# require './display'
require 'set'

# main class
class Main
  def self.play(width = 9, height = 9, num_mines = 10, player = GeekPlayer.new)
    include Displays

    minefield = RectangularMinefield.new(width, height, num_mines)
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

Main.benchmark(30, 16, 99, 100)

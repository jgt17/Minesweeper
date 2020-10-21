# frozen_string_literal: true

require './minefields/rectangular_minefield'
require './players/random_player'
require './players/nerd_player'
# require './display'
require 'set'

class Main
  def self.play
    include Displays

    minefield = RectangularMinefield.new(30, 16, 99)
    puts DISPLAY
    DISPLAY.call minefield
    sheldon = NerdPlayer.new
    sheldon.play(minefield)
  end

  def self.benchmark(width, height, mines, runs)
    games_won = 0
    sheldon = NerdPlayer.new
    runs.times do |i|
      puts i if (i % (runs / 100)).zero?
      minefield = RectangularMinefield.new(width, height, mines)
      games_won += 1 if sheldon.play(minefield)
    end
    puts games_won.to_f / runs
  end
end

Main.benchmark(16, 16, 40, 1000)

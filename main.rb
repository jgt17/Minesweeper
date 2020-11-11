# frozen_string_literal: true

require './game_resources/minefields/rectangular_minefield'
require './players/random_player'
require './players/nerd_player'
require './players/geek_player'
require './stats'
# require './display'
require 'set'

# main class
class Main
  def self.play(minefield = RectangularMinefield.new, player = GeekPlayer.new)
    include Displays
    include Stats

    DISPLAY.call minefield
    player.play(minefield)
  end

  def self.benchmark(width, height, mines, runs, player = GeekPlayer.new)
    games_won = 0
    runs.times do |i|
      puts "  #{i}" if (i % (runs / 10)).zero?
      minefield = RectangularMinefield.new(width, height, mines)
      games_won += 1 if player.play(minefield)
    end
    games_won.to_f / runs
  end

  def self.comprehensive_benchmark(runs_per_set, sets, player = GeekPlayer.new)
    results = {}
    puts 'Running Beginner levels'
    beginner_results = Array.new(sets) do |i|
      puts i
      benchmark(9, 9, 10, runs_per_set, player)
    end
    results[:Beginner] = { Mean: Stats.mean(beginner_results), Sigma: Stats.std_dev(beginner_results) }
    puts 'Running Intermediate levels'
    intermediate_results = Array.new(sets) do |i|
      puts i
      benchmark(16, 16, 40, runs_per_set, player)
    end
    results[:Intermediate] = { Mean: Stats.mean(intermediate_results), Sigma: Stats.std_dev(intermediate_results) }
    puts 'Running Expert levels'
    expert_results = Array.new(sets) do |i|
      puts i
      benchmark(30, 16, 99, runs_per_set, player)
    end
    results[:Expert] = { Mean: Stats.mean(expert_results), Sigma: Stats.std_dev(expert_results) }
    puts results
  end

  def self.time_trial(runs_per_set, sets, player = GeekPlayer.new)
    results = {}
    puts 'Running Beginner levels'
    beginner_results = Array.new(sets) do |i|
      puts i
      t1 = Time.now
      benchmark(9, 9, 10, runs_per_set, player)
      (Time.now - t1).to_f / runs_per_set
    end
    results[:Beginner] = { Mean: Stats.mean(beginner_results), Sigma: Stats.std_dev(beginner_results) }
    puts 'Running Intermediate levels'
    intermediate_results = Array.new(sets) do |i|
      puts i
      t1 = Time.now
      benchmark(16, 16, 40, runs_per_set, player)
      (Time.now - t1).to_f / runs_per_set
    end
    results[:Intermediate] = { Mean: Stats.mean(intermediate_results), Sigma: Stats.std_dev(intermediate_results) }
    puts 'Running Expert levels'
    expert_results = Array.new(sets) do |i|
      puts i
      t1 = Time.now
      benchmark(30, 16, 99, runs_per_set, player)
      (Time.now - t1).to_f / runs_per_set
    end
    results[:Expert] = { Mean: Stats.mean(expert_results), Sigma: Stats.std_dev(expert_results) }
    puts results
  end
end

# Todo generalize benchmark to different minefield types (implement generating minefield from other)
# Main.benchmark(9, 9, 10, 100)
# Main.comprehensive_benchmark(200, 500)
Main.time_trial(200, 500)
# Main.play

# TODO: support non-random first guesses

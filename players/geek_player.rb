# frozen_string_literal: true

require './fact'
require './cell'
require './move'
require './display'
require 'set'

# a player that uses facts to make inferences and play intelligently
# uses the same underlying logic as NerdPlayer, but storing facts in
# a hash instead of a heap should improve runtimes dramatically
# I realized I don't need as much ordering on the Facts as I thought
# I did, and maintaining that ordering takes a lot of runtime
class GeekPlayer < Player
  def initialize
    super
    @uncertain_facts = Set.new
    @certain_facts = Set.new
    @move_queue = []
    @global_fact_added = false
  end

  def notify_revealed(cell)
    remove_cell_from_facts(cell)
    @move_queue.delete(cell)
    add_fact_from_cell(cell)
  end

  protected

  def choose_move
    DISPLAY.call @minefield
    DISPLAY.call "#{@minefield.num_flagged} mines flagged"
    DISPLAY.call 'Choosing Move'
    DISPLAY.call 'Move Queue'
    DISPLAY.call @move_queue.empty? ? '[]' : @move_queue
    return make_move_from_queue unless @move_queue.empty?

    prune # make as many moves as possible between prunes
    attempt_inject_global_fact if @uncertain_facts.empty? && @certain_facts.empty?
    return make_move_from_queue unless @move_queue.empty?

    until !@certain_facts.empty? || !infer; end
    DISPLAY.call 'Made some inferences'
    DISPLAY.call 'Facts'
    DISPLAY.call 'Certain Facts'
    DISPLAY.call @certain_facts.to_a
    DISPLAY.call 'Uncertain Facts'
    DISPLAY.call @uncertain_facts.to_a
    unless !@certain_facts.empty? || @global_fact_added
      attempt_inject_global_fact
      return choose_move
    end
    @certain_facts.empty? ? add_safest_guess_to_queue : load_certain_moves_to_queue
    DISPLAY.call 'Move Queue'
    DISPLAY.call @move_queue.empty? ? '[]' : @move_queue
    make_move_from_queue
  end

  def setup(minefield)
    super
    @uncertain_facts = Set.new
    @certain_facts = Set.new
    @move_queue = []
    @global_fact_added = false
  end

  def flag(cell)
    super
    remove_cell_from_facts(cell, true)
  end

  private

  def make_move_from_queue
    @move_queue.pop
  end

  def remove_cell_from_facts(cell, flagged = false)
    flag_or_reveal = flagged ? Fact.instance_method(:flag_cell) : Fact.instance_method(:reveal_cell)
    @certain_facts.each { |fact| flag_or_reveal.bind(fact).call(cell) }
    @uncertain_facts.each do |fact|
      flag_or_reveal.bind(fact).call(cell)
      if fact.certain?
        @uncertain_facts.delete(fact)
        add_fact(fact)
      end
    end
  end

  def add_fact_from_cell(cell)
    fact = Fact.new(cell.hidden_and_unflagged_neighbors,
                    cell.num_neighboring_mines - cell.flagged_neighbors.length)
    return if fact.empty?

    add_fact(fact)
  end

  # iterate over the known uncertain facts and attempt to derive new ones
  # returns true if at least one fact was able to be inferred, else false
  def infer
    new_facts = Set.new
    @uncertain_facts.each { |n| @uncertain_facts.each { |m| new_facts |= n.infer(m).reject(&:empty?) } }
    # inferences are not commutative
    fact_added = false
    new_facts.each { |fact| fact_added = !add_fact(fact) || fact_added }
    fact_added
  end

  def prune
    @uncertain_facts.delete_if(&:empty?)
    @certain_facts.delete_if(&:empty?)
  end

  def add_safest_guess_to_queue
    safest_fact = nil
    @uncertain_facts.each { |fact| safest_fact = fact if safest_fact.nil? || safest_fact.safety > fact.safety }
    raise 'No moves' if safest_fact.nil?

    @move_queue.push(Move.new(safest_fact.random_cell, false))
  end

  def load_certain_moves_to_queue
    moves = Set.new
    @certain_facts.each { |fact| fact.cells.each { |cell| moves.add(Move.new(cell, fact.safety.zero?)) } }
    @move_queue.concat moves.to_a
  end

  def add_fact(fact)
    raise 'Expected a fact' unless fact.is_a? Fact
    raise 'Added empty fact' if fact.empty?

    fact.certain? ? @certain_facts.add?(fact) : @uncertain_facts.add?(fact)
  end

  def attempt_inject_global_fact
    return if @global_fact_added

    DISPLAY.call 'Injecting Global Fact'
    global_fact = Fact.new(@minefield.hidden_and_unflagged_cells, @minefield.num_mines - @minefield.num_flagged)
    # prevent global fact from being added too early
    if global_fact.cells.size < 10
      add_fact(global_fact)
      @global_fact_added = true
    else
      DISPLAY.call 'Failed, Global Fact still too large'
      add_safest_guess_to_queue
    end
  end
end

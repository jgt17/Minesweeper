# frozen_string_literal: true

require './fact'
require './fact_heap'
require './cell'
require './move'
require './display'

# a player that uses facts to make inferences and play intelligently
class NerdPlayer < Player
  def initialize
    super
    @facts = FactHeap.new
    @move_queue = []
  end

  def notify_revealed(cell)
    remove_cell_from_facts(cell)
    @move_queue.delete(cell)
    add_fact_from_cell(cell)
  end

  protected

  def choose_move
    DISPLAY.call @minefield
    DISPLAY.call 'Choosing Move'
    DISPLAY.call 'Move Queue'
    DISPLAY.call @move_queue.empty? ? '[]' : @move_queue
    return make_move_from_queue unless @move_queue.empty?

    until @facts.peek.certain? || !infer; end
    DISPLAY.call 'Made some inferences'
    DISPLAY.call 'Facts'
    @facts.display_heap
    flag = @facts.peek.safety.zero?
    @facts.peek.certain? ? @facts.pop.cells.to_a.each { |cell| @move_queue.push(Move.new(cell, flag)) } : @move_queue.push(Move.new(Set.new(@facts.peek.cells).to_a.sample, false))
    DISPLAY.call @move_queue.empty? ? '[]' : @move_queue
    make_move_from_queue
  end

  def setup(minefield)
    super
    @facts = FactHeap.new
    # initialize the FactHeap with the entire board
    # needed for some edge cases
    @facts.push(Fact.new(@minefield.all_cells, @minefield.num_mines))
    @move_queue = []
  end

  def clean_up
    super
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
    @facts.reveal_or_flag_cell(cell, flagged)
  end

  def add_fact_from_cell(cell)
    fact = Fact.new(cell.hidden_and_unflagged_neighbors,
                    cell.num_neighboring_mines - cell.flagged_neighbors.length)
    @facts.push(fact) unless fact.empty?
  end

  def infer
    @facts.infer
  end
end

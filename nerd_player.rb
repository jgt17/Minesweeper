# frozen_string_literal: true

require './core_extensions'
require './fact'
require './fact_heap'
require './cell'

# a player that uses facts to make inferences and play intelligently
class NerdPlayer < Player
  def initialize
    super
    @facts = FactHeap.new
    @move_queue = []
  end

  def notify_revealed(cell)
    remove_cell_from_facts(cell)
    add_fact_from_cell(cell)
  end

  protected

  def choose_move
    return make_move_from_queue unless @move_queue.empty

    until @facts.peek.certain? || !infer; end

    flag = safety.zero?
    @facts.pop.each { |cell| @move_queue.push(Move.new(cell, flag)) }
    make_move_from_queue
  end

  def setup(minefield)
    super
    @facts = FactHeap.new
    # initialize the FactHeap with the entire board
    # needed for some edge cases
    @facts.push(Fact(@minefield.all_cells.to_set, @minefield.num_mines))
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
    @facts.push(Fact.new(cell.hidden_and_unflagged_neighbors, cell.num_neighboring_mines))
  end

  def infer
    @facts.infer
  end
end

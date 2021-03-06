# frozen_string_literal: true

require_relative './fact_management/fact'
require_relative '../game_resources/cell'
require_relative '../game_resources/move'
require_relative '../display'
require_relative './fact_management/fact_hash'

# a player that uses facts to make inferences and play intelligently
# uses the same underlying logic as NerdPlayer, but storing facts in
# a hash instead of a heap improves runtimes dramatically
# I realized I don't need as much ordering on the Facts as I thought
# I did, and maintaining that ordering takes a lot of runtime
class GeekPlayer < Player
  def initialize
    super
    @facts = FactHash.new
    @move_queue = []
    @global_fact_added = false
  end

  def notify_revealed(cell)
    remove_cell_from_facts(cell)
    @move_queue.delete(Move.new(cell, false))
    add_fact_from_cell(cell)
  end

  def notify_flagged(cell)
    remove_cell_from_facts(cell, true)
  end

  protected

  def choose_move
    show_game_state
    return make_move_from_queue unless @move_queue.empty?

    prune # make as many moves as possible between prunes

    # infer until at least one certainty is discovered or no more Facts can be inferred
    until @facts.any_certain? || !infer; end
    show_facts

    return choose_move unless @facts.any_certain? || !attempt_inject_global_fact

    # rest @global_fact_added to remove large facts after making inferences
    # from the global fact to prevent @facts size from exploding
    @global_fact_added = false
    load_pending_moves
    make_move_from_queue
  end

  def setup(minefield)
    super
    @facts = FactHash.new
    @move_queue = []
    @global_fact_added = false
  end

  private

  def make_move_from_queue
    @move_queue.pop
  end

  def remove_cell_from_facts(cell, flagged = false)
    @facts.remove_cell_from_facts(cell, flagged)
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
    return false if !@facts.any_uncertain? || @facts.size > 60 # sacrifice a bit of accuracy for runtime

    DISPLAY.call 'Inferring'
    DISPLAY.call @facts.size
    @facts.make_inferences
  end

  # attempts to add a set of facts to the fact heap, returns true if at least one was successfully added, else false
  def add_new_facts(set_of_facts)
    @facts.add_all(set_of_facts)
  end

  # remove empty or excessively large facts from the fact heap
  def prune
    DISPLAY.call 'pruning'
    @facts.prune
    @facts.prune_large unless @global_fact_added
    # remove large facts after making inferences from the global fact to prevent uncertain_facts size from exploding
  end

  # choose one of the safest guesses from the available knowledge and add it to the move queue
  # todo non-naive guessing
  def add_safest_guess_to_queue
    @move_queue.push(Move.new(@facts.safest_fact(create_global_fact).random_cell, false))
  end

  # add all the moves represented by the set of certain facts to the move queue
  def load_certain_moves_to_queue
    @move_queue.concat @facts.pop_certain_moves
  end

  # add a fact to the heap
  def add_fact(fact)
    raise 'Expected a fact' unless fact.is_a? Fact
    return false if fact.empty?

    @facts.add(fact)
  end

  # attempt to add the global board state to the known facts, possibly opening up new inferences
  def attempt_inject_global_fact
    return false if @global_fact_added

    DISPLAY.call 'Injecting Global Fact'
    global_fact = create_global_fact
    # prevent global fact from being added too early
    if global_fact.cells.size < 16
      add_fact(global_fact)
      @global_fact_added = true
    else
      DISPLAY.call 'Failed, Global Fact still too large'
    end
    @global_fact_added
  end

  # get the global fact at any given point in the game
  def create_global_fact
    Fact.new(@minefield.hidden_and_unflagged_cells, @minefield.num_mines - @minefield.num_flagged)
  end

  def show_game_state
    DISPLAY.call @minefield
    DISPLAY.call "#{@minefield.num_flagged} mines flagged"
    DISPLAY.call "Choosing Move\n"
    DISPLAY.call @move_queue.empty? ? '[]' : @move_queue
  end

  def show_facts
    DISPLAY.call 'Facts'
    DISPLAY.call @facts
  end

  def load_pending_moves
    @facts.any_certain? ? load_certain_moves_to_queue : add_safest_guess_to_queue
    DISPLAY.call 'Move Queue'
    DISPLAY.call @move_queue.empty? ? '[]' : @move_queue
  end
end

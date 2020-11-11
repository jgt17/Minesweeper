# frozen_string_literal: true

require_relative './fact'
require 'set'

# object responsible for maintaining facts for GeekPlayer
class FactHash
  def initialize
    @certain_facts = Set.new
    @uncertain_facts = Set.new
  end

  def delete(fact)
    @certain_facts.delete(fact)
    @uncertain_facts.delete(fact)
  end

  def add(fact)
    return @certain_facts.add?(fact) if fact.certain?

    @uncertain_facts.add?(fact)
  end

  def add_all(set_of_facts)
    fact_added = false
    set_of_facts.each { |fact| fact_added = add(fact) || fact_added }
    fact_added
  end

  # remove a cell from all facts in the hash
  # returns a Set of Facts that changed
  def remove_cell_from_facts(cell, flagged = false)
    flag_or_reveal = flagged ? Fact.instance_method(:flag_cell!) : Fact.instance_method(:reveal_cell!)
    updated_facts = Set.new
    remove_cell(@certain_facts, cell, flag_or_reveal, updated_facts)
    remove_cell(@uncertain_facts, cell, flag_or_reveal, updated_facts)
    updated_facts.each { |fact| add(fact) }
  end

  def any_certain?
    !@certain_facts.empty?
  end

  def any_uncertain?
    !@uncertain_facts.empty?
  end

  def size
    @uncertain_facts.size + @certain_facts.size
  end

  def make_inferences
    new_facts = Set.new
    @uncertain_facts.each { |n| @uncertain_facts.each { |m| new_facts |= n.infer(m).reject(&:empty?) } }
    # inferences are not commutative
    add_all(new_facts)
  end

  def prune
    @uncertain_facts.delete_if(&:empty?)
    @certain_facts.delete_if(&:empty?)
  end

  def prune_large
    @uncertain_facts.delete_if { |fact| fact.size > 8 }
  end

  def safest_fact(global_fact)
    safest_fact = global_fact
    @uncertain_facts.each { |fact| safest_fact = fact if safest_fact.safety < fact.safety }
    safest_fact
  end

  def pop_certain_moves
    moves = Set.new
    @certain_facts.each { |fact| fact.cells.each { |cell| moves.add(Move.new(cell, fact.safety.zero?)) } }
    @certain_facts = Set.new
    moves.to_a
  end

  def to_s
    str = +"Certain Facts: \n"
    @certain_facts.each { |fact| str += "#{fact}\n" }
    str += "\nUncertain Facts: \n"
    @uncertain_facts.each { |fact| str += "#{fact}\n" }
    str
  end

  private

  def remove_cell(facts, cell, flag_or_reveal, updated_facts)
    facts.each do |fact|
      next unless fact.include?(cell)

      facts.delete(fact)
      flag_or_reveal.bind(fact).call(cell)
      updated_facts.add(fact)
    end
  end
end

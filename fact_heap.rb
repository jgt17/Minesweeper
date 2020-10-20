# frozen_string_literal: true

require './display'

# implements a binary heap of Facts on an Array
# certainty is considered first, then safety
class FactHeap
  def initialize
    @heap = []
  end

  def size
    @heap.length
  end

  def push(fact)
    # don't add empty or equivalent facts to the heap
    return if fact.nil? || fact.empty? || @heap.include?(fact)

    @heap.push(fact)
    sift_up(-1)
  end

  def pop
    swap(0, -1)
    return_cell = @heap.pop
    sift_down(0)
    return_cell
  end

  def peek
    @heap[0]
  end

  def delete(fact)
    cell_index = @heap.index(fact)
    # raise "attempted to delete a cell that doesn't exist" if cell_index.nil?
    return nil if cell_index.nil?

    swap(cell_index, -1)
    @heap.pop
    return fact if cell_index == @heap.length

    if cell_index.positive? && @heap[parent(cell_index)].compare_with(@heap[cell_index]).positive?
      sift_up(cell_index)
    else
      sift_down(cell_index)
    end
    fact
  end

  # might not need each
  def each(&block)
    @heap.each(&block)
  end

  def reveal_or_flag_cell(cell, flagged)
    updated = []
    flag_or_reveal = flagged ? Fact.instance_method(:flag_cell) : Fact.instance_method(:reveal_cell)
    @heap.each { |fact| updated.append(fact) if flag_or_reveal.bind(fact).call(cell) }
    prune
    updated.uniq!
    updated.each { |fact| delete(fact) }
    updated.each { |fact| push(fact) unless fact.nil? }
  end

  def infer
    new_facts = []
    @heap.each { |fact| @heap.each { |other| new_facts.concat(fact.infer(other).reject(&:empty?) - @heap) } }
    # inferences are not commutative
    new_facts.each { |fact| push(fact) }
    new_facts.length.zero? ? nil : new_facts
  end

  def display_heap
    DISPLAY.call @heap
  end

  private

  # remove now-empty facts from the heap
  def prune
    @heap.select(&:empty?).each { |fact| delete(fact) }
  end

  def sift_up(index)
    index += @heap.length if index.negative?
    parent = parent(index)
    return index if parent.nil?

    return index unless @heap[index].compare_with(@heap[parent]).positive?

    swap(index, parent)
    sift_up(parent)
  end

  def sift_down(index)
    index += @heap.length if index.negative?
    left = left_child(index)
    return index if left.nil?

    right = right_child(index)
    child = right.nil? || @heap[left].compare_with(@heap[right]).positive? ? left : right
    return index unless @heap[index].compare_with(@heap[child]).negative?

    swap(index, child)
    sift_down(child)
  end

  def swap(index1, index2)
    temp = @heap[index1]
    @heap[index1] = @heap[index2]
    @heap[index2] = temp
  end

  def parent(index)
    index += @heap.length if index.negative?
    index.zero? ? nil : (index - 1) / 2
  end

  def left_child(index)
    index += @heap.length if index.negative?
    left_child = 2 * index + 1
    left_child < @heap.length ? left_child : nil
  end

  def right_child(index)
    index += @heap.length if index.negative?
    right_child = 2 * index + 2
    right_child < @heap.length ? right_child : nil
  end
end

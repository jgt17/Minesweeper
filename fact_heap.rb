# frozen_string_literal: true

# implements a binary heap of Facts on an Array
# certainty is considered first, then safety
class FactHeap
  def initialize
    @heap = []
  end

  def size
    @heap.length
  end

  def push(cell)
    @heap.push(cell)
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
    raise "attempted to delete a cell that doesn't exist" if cell_index.nil?

    swap(cell_index, -1)
    @heap.pop
    @heap[cell_index].compare_with(fact) ? sift_up(cell_index) : sift_down(cell_index)
  end

  private

  def sift_up(index)
    parent = parent(index)
    return index if parent.nil?
    return index unless @heap[index].compare_with(@heap[parent]).positive?

    swap(index, parent)
    sift_up(parent)
  end

  def sift_down(index)
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
    index.zero? ? nil : (index - 1) / 2
  end

  def left_child(index)
    left_child = 2 * index + 1
    left_child < length ? left_child : nil
  end

  def right_child(index)
    right_child = 2 * index + 1
    right_child < length ? right_child : nil
  end
end

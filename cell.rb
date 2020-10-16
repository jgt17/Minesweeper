# class representing an individual cell of the minefield
class Cell
  attr_accessor :revealed
  attr_accessor :flagged
  attr_reader :is_mine
  attr_reader :neighbors
  attr_reader :position

  def initialize(is_mine = false)
    @revealed = false
    @flagged = false
    @is_mine = is_mine
    @neighbors = []
    # @hidden_symbol =
  end

  # add a neighboring cell
  def add_neighbor(other_cell)
    raise Error 'Expected a cell' unless other_cell.is_a?(Cell)

    @neighbors.append(other_cell)
  end

  # check if this cell and the other cell are neighbors
  def neighbors?(other_cell)
    @neighbors.include?(other_cell)
  end

  # attempt to access the number of mines neighboring this cell
  def num_neighboring_mines=
    @revealed ? @num_neighbor_mines : nil
  end

  def to_s
    return '□' unless @revealed # an empty box
    return '◈' if @is_mine # an explosion symbol

    @num_neighbor_mines.zero? ? '○' : @num_neighbor_mines
  end

  # reveal the contents of a cell
  def reveal
    return false if @flagged || @revealed

    @revealed = true
    @is_mine ? nil : @num_neighbor_mines
  end

  # set a cell to be a mine
  def set_mine
    @is_mine = true
    @neighbors.each(&:incr_neighbor_mines)
  end

  private

  def incr_neighbor_mines
    @num_neighbor_mines += 1
  end
end

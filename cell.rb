class Cell
  attr_accessor :revealed
  attr_accessor :flagged
  attr_reader :is_mine
  attr_reader :neighbors
  attr_reader :position

  def initialize(position, is_mine = false)
    @revealed = false
    @flagged = false
    @is_mine = is_mine
    @position = position
  end

  def neighbors=(neighbors)
    @neighbors ||= neighbors
    @num_neighbor_mines = count_neighboring_mines unless @is_mine
  end

  def num_neighboring_mines=
    @revealed ? @num_neighbor_mines : nil
  end

  def to_s
    return '\u20DE' unless @revealed # an empty box

    return '\u1F4A5' if @is_mine # an explosion symbol

    @num_neighbor_mines == 0 ? '.' : @num_neighbor_mines
  end

  private

  def count_neighboring_mines
    n = 0
    @neighbors.each { |neighbor| n += 1 if neighbor.is_mine }
  end
end

class Move
  attr_reader :cell

  def initialize(cell, flag)
    @cell = cell
    @flag = flag
  end

  def flag?
    @flag
  end
end

# frozen_string_literal: true

require './minefield'
require './cell'
require './display'

# abstract player
class Player
  def initialize
    @dummy_minefield = Minefield.new(1, 0)
    @minefield = @dummy_minefield
  end

  # play the given minefield
  def play(minefield)
    raise 'Already playing a game!' unless @minefield == @dummy_minefield

    setup(minefield)
    DISPLAY.call @minefield
    reveal @minefield.cell_at(@minefield.first_click)
    make_move(choose_move) until @minefield.clear?
    DISPLAY.call 'Victory!'
    DISPLAY.call @minefield
    clean_up
  end

  # implementations of Player should overwrite the methods below as appropriate
  # setup and clean_up should call super

  # triggered when the minefield successfully reveals a cell, either from a chosen move or cascading reveal
  def notify_revealed(cell); end

  # get the player's first click choice, otherwise random
  # to be implemented by children
  def choose_first_click; end

  protected

  # choose the next cell to reveal or flag/unflag
  def choose_move
    raise 'No strategy defined.'
  end

  # initialize the game state
  def setup(minefield)
    raise 'Expected a minefield' unless minefield.is_a? Minefield

    @minefield = minefield
    @minefield.player = self
  end

  # reset the player state to prepare for a new game
  def clean_up
    @minefield = @dummy_minefield
  end

  # end of methods to be overwritten, the ones below should be left alone

  # "click" a cell
  def reveal(cell)
    if cell.flagged?
      DISPLAY.call 'Attempted to reveal flagged cell.'
    else
      announce_reveal(cell)
      @minefield.reveal(cell)
    end
  end

  # mark a cell as a mine without revealing it
  def flag(cell)
    announce_flag(cell)
    @minefield.flag(cell)
  end

  # unmark a cell as a mine so it can be revealed
  def unflag(cell)
    announce_unflag(cell)
    @minefield.unflag(cell)
  end

  def announce_reveal(cell)
    DISPLAY.call "Revealing #{@minefield.position_of(cell)}"
  end

  def announce_flag(cell)
    DISPLAY.call "Flagging #{@minefield.position_of(cell)}"
  end

  def announce_unflag(cell)
    DISPLAY.call "Unflagging #{@minefield.position_of(cell)}"
  end

  def make_move(move)
    move.flag? ? flag(move.cell) : reveal(move.cell)
  end
end

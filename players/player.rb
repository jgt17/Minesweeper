# frozen_string_literal: true

require_relative '../game_resources/minefields/minefield'
require_relative '../game_resources/cell'
require_relative '../display'
require_relative '../game_resources/tripped_mine_error'

# abstract player
class Player
  include Displays
  def initialize
    @minefield = nil
  end

  # play the given minefield
  def play(minefield)
    raise 'Already playing a game!' unless @minefield.nil?

    setup(minefield)
    DISPLAY.call @minefield
    reveal @minefield.cell_at(@minefield.first_click)
    won = play_out
    DISPLAY.call @minefield
    clean_up
    won
  end

  # implementations of Player should overwrite the methods below as appropriate
  # setup and clean_up should call super

  # triggered when the minefield successfully reveals a cell, either from a chosen move or cascading reveal
  def notify_revealed(cell); end

  # triggered when the minefield successfully flags a cell
  def notify_flagged(cell); end

  # triggered when the minefield successfully removes a flag from a cell
  def notify_unflagged(_cell); end

  # get the player's first click choice, otherwise random
  # to be implemented by children
  def choose_first_click; end

  private

  # keep making moves until the game is won or lost, return true if won, else false
  def play_out
    begin
      make_move(choose_move) until @minefield.clear?
      DISPLAY.call 'Victory!'
    rescue TrippedMineError
      DISPLAY.call 'Boom!'
      return false
    end
    true
  end

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
    @minefield = nil
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

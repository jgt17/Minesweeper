# frozen_string_literal: true

# different display modes for the minefield and AI processes
module Displays
  # default display, print to console
  def self.text_display(obj)
    puts obj
  end

  # blank display, print nothing. mostly for performance testing
  def self.blank_display(obj); end

  # TODO: graphical display?

  # display mode
  DISPLAY = method :blank_display
end

# visual display at some point?

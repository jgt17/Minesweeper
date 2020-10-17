# frozen_string_literal: true

module CoreExtensions
  # adds a method to Set that adds objects to the set only if they are non-nil
  module Set
    def safe_add(o)
      add(o) unless o.nil?
    end
  end
end

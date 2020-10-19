# frozen_string_literal: true

module CoreExtensions
  # adds a method to Set that adds objects to the set only if they are non-nil
  module Set
    def safe_add(obj)
      add(obj) unless obj.nil?
    end
  end
end

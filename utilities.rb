# frozen_string_literal: true

# various utility methods
module Utilities
  def check_integer_param(param, param_name)
    error_string = "#{param_name} must be a non-negative integer. Given #{param_name}: '#{param}'"
    raise error_string unless param.is_a?(Integer) && !param.negative?

    true
  end

  def neighboring_range(val, max)
    ((val - 1 >= 0 ? val - 1 : 0)..(val + 1 < max ? val + 1 : max))
  end

  def neighboring_ranges(val1, max1, val2, max2)
    [neighboring_range(val1, max1), neighboring_range(val2, max2)]
  end
end

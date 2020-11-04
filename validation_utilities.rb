module ValidationUtilities
  # check that the supplied parameter is a positive integer
  def check_integer_param(param, param_name)
    error_string = "#{param_name} must be a positive integer. Given #{param_name}: '#{param}'"
    raise error_string unless param.is_a?(Integer) && param.positive?

    true
  end
end
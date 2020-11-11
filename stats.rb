# frozen_string_literal: true

# quick and dirty stats for benchmarking
module Stats
  def self.mean(ary)
    total = 0
    ary.each { |el| total += el }
    total.to_f / ary.size
  end

  def self.variance(ary)
    m = mean(ary)
    total = 0
    ary.each { |v| total += (v - m)**2 }
    total.to_f / ary.size
  end

  def self.std_dev(ary)
    Math.sqrt(variance(ary))
  end
end

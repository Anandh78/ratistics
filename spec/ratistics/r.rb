# Ruby versions of common R functions exported to the global namespace

require 'ratistics'

def c(*sample, &block)
  if block_given?
    return Ratistics.collect(sample, &block)
  else
    return sample
  end
end

def mean(sample, &block)
  return Ratistics.mean(sample, &block)
end

def median(sample, &block)
  return Ratistics.median(sample, &block)
end

def sd(sample, &block)
  return Ratistics.standard_deviation(sample, &block)
end

def var(sample, &block)
  return Ratistics.variance(sample, &block)
end

def min(sample, &block)
  return Ratistics.min(sample, &block)
end

def max(sample, &block)
  return Ratistics.max(sample, &block)
end

def q()
  exit
end

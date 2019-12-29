def describe(description, &block)
  puts "#{description}"
  block.call
end

# these are called ANSI escape codes
GREEN = "\e[32m"
RED = "\e[31m"
RESET = "\e[0m"

def it(description, &block)
  begin
    # this just does not create a new line at the end of it
    $stdout.write "#{description}"
    block.call
    puts " #{GREEN}(ok)#{RESET}"
  rescue Exception => e
    puts " #{RED}(fail)#{RESET}"
    puts e
    puts e.backtrace
  end
end

# Allows you to invoke #should on any evaluation
class Object
  def should
    # you should declare objects whenever necessary to make your
    # code much more readable
    ComparisonAssertion.new(self)
  end
end

class ComparisonAssertion
  def initialize(actual)
    @actual = actual
  end

  def ==(expected)
    unless @actual == expected
      raise AssertionError.new(
        "Expected #{expected.inspect}, but got #{@actual.inspect} instead."
      )
    end
  end
end

class AssertionError < RuntimeError
end
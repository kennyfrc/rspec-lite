# these are called ANSI escape codes
GREEN = "\e[32m"
RED = "\e[31m"
RESET = "\e[0m"


def describe(description, &block)
  puts "#{description}"
  block.call
end

def it(description, &block)
  begin
    # this just does not create a new line at the end of it
    $stdout.write "#{description}"
    block.call
    puts " #{GREEN}(ok)#{RESET}"
  rescue Exception => e
    puts " #{RED}(fail)#{RESET}"
    puts "\t#{RED}* Backtrace: #{RESET}"
    puts [
      e.backtrace.reverse,
      "#{RED}#{e}#{RESET}"
    ].flatten.map {|line| "\t#{RED}| #{RESET}#{line}"}.join("\n")
  end
end

def expect(actual = nil, &block)
  Actual.new(actual || block)
end

def raise_error(error_name)
  Error.new(error_name)
end

def eq(expected)
  Expectation.new(expected)
end

class Actual
  def initialize(actual)
    @actual = actual
  end

  # what's new to you: passing objects as arguments
  def to(expectation) 
    expectation.run(@actual)
  end
end

class Error
  def initialize(error_name)
    @error_name = error_name
  end

  def run(actual_block)
    begin
      actual_block.call
    rescue @error_name
      return
    rescue StandardError => e
      raise AssertionError.new(
        format("We were expecting %s, but we saw %s",
          @error_name.inspect,
          e.inspect
        )
      )
    end

    raise AssertionError.new(
      format("We were expecting %s, but we got nothing",
        @error_name.inspect
      )
    )
  end
end

class Expectation
  def initialize(expected)
    @expected = expected
  end

  def run(actual)
    unless actual == @expected
      raise AssertionError.new(
        "Expected #{@expected.inspect}, but got #{actual.inspect} instead."
      )
    end
  end
end

class AssertionError < RuntimeError
end
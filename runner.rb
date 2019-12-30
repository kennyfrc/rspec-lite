# these are called ANSI escape codes
GREEN = "\e[32m"
RED = "\e[31m"
RESET = "\e[0m"

def describe(description, &block)
  Describe.new(description, block).run
end

class Describe
  def initialize(description, block)
    @description = description
    @block = block
    @lets = {}
    @befores = []
  end

  def run
    puts "#{@description}"
    # this runs the block as if it's
    # a method on the calling object
    instance_eval(&@block)
  end

  def it(description, &block)
    It.new(description, @lets, @befores, block).run
  end

  def let(name, &block)
    @lets[name] = block
  end

  def before(&block)
    @befores << block
  end
end

class It
  def initialize(description, lets, befores, block)
    @description = description
    @block = block
    @lets = lets
    # lets_cache ensures that you 
    # always return the same object
    @lets_cache = {}
    @befores = befores
  end

  def run
    begin
      # this just does not create a new line at the end of it
      $stdout.write "#{@description}"
      # used to be block.call
      @befores.each { |block| instance_eval(&block)}
      instance_eval(&@block)
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

  def method_missing(name)
    # fetch the block assigned to the method name
    # call the block as if it's a method of It

    # if it exists in the cache, just return it
    if @lets_cache.key?(name)
      @lets_cache[name]
    else
      # for methods that don't exist,
      # call super which allows you to 
      # raise an exception
      value = instance_eval(&@lets.fetch(name) { super })
      @lets_cache[name] = value
      value
    end
  end
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
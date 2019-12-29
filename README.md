### Rspec Lite

This is a learning project to help learn the internals of Rspec.

### New techniques learned

ANSI escape codes allow you to color code stuff on the terminal
```
# these are called ANSI escape codes
GREEN = "\e[32m"
RED = "\e[31m"
RESET = "\e[0m"
```

Inside the method where you expect errors (especially with blocks around), you should put some exception handlers there

```
# LEVEL ONE
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

# LEVEL TWO (falls within a method of the method with the exception handling)

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

```

If you need you, you can add methods on an Object level if it applies to all aspects in your code. This makes a lot of sense especially when it comes to testing.

```
# Allows you to invoke #should on any evaluation
class Object
  def should
    # you should declare objects whenever necessary to make your
    # code much more readable
    ComparisonAssertion.new(self)
  end
end
```
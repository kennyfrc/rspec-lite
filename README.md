## Rspec Lite

This is a learning project to help learn the internals of Rspec.

### How to use

Just run a spec file

```
ruby spec/example_spec.rb
```

### New techniques learned

1. ANSI escape codes allow you to color code stuff on the terminal
```
# these are called ANSI escape codes
GREEN = "\e[32m"
RED = "\e[31m"
RESET = "\e[0m"
```

2. Inside the method where you expect errors (especially with blocks around), you should put some exception handlers there

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

3. If you need to, you can add methods on an Object level if it applies to all aspects in your code. This makes a lot of sense especially when it comes to testing.

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

4. Whenever you are testing attributes within objects, there are two recommended approaches (both are valid):

```
# 4.1. Test a single attribute
describe User do
  def user
    @user ||= User.create(email: 'kenn@askmonolith.com', last_login: Time.new(2019, 12, 29, 17, 22))
  end

  it "has some attributes" do
    user.email.should == 'kenn@askmonolith.com'
  end
end

# 4.2. Test against the entire object through user.to_hash whenever you're using Sequel and user.as_json[0] if you're using ActiveRecord

describe User do
  def user
    @user ||= User.create(email: 'kenn@askmonolith.com', last_login: Time.new(2019, 12, 29, 17, 22))
  end

  it "has some attributes" do
    user.as_json[0] = {
      id: user.id,
      email: 'kenn@askmonolith.com'
      last_login: Time.new(2019, 12, 29, 17, 22)
    }
  end
end

```
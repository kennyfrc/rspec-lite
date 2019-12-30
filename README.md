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


5. `instance-eval` X on a Y object. 

Use case: when you have a lot of global methods and you need to move them into an object, like in the case of:
```
describe "expectations" do
  it "can pass" do
    # expect(1 + 1).to(eq(2))
    expect(1 + 1).to eq 2
  end

  it "can take a block" do
    expect do
      raise ArgumentError.new
    end.to raise_error(ArgumentError)
  end
end
```

The need for this normally arises when you need to move a block of code...
```
# from
block.call
# to
instance_eval(&@block)
```


What `instance_eval(&@block)` does is that it runs the block of code as if it's a instance method of the object. 

In order to set the context, the variable self is set to obj while the code is executing, giving the code access to obj’s instance variables and private methods.

```
class KlassWithSecret
  def initialize
    @secret = 99
  end
  private
  def the_secret
    "Ssssh! The secret is #{@secret}."
  end
end
k = KlassWithSecret.new
k.instance_eval { @secret }          #=> 99
k.instance_eval { the_secret }       #=> "Ssssh! The secret is 99."
k.instance_eval {|obj| obj == self } #=> true
```

6. `method_missing`

Use cases
* Dealing with repetitive methods
* Delegating method calls to another object

It's sort of like a Begin/Rescue, but for method calls. It gives you one last chance to deal with that method call before an exception is raised.

It's a method in ruby that allows you handle situations where a method in the calling object doesn't exist.

* The first is the name of the method you were trying to call.
* The second is the args (args) that were passed to the method.
* The third is a block (&block) that was passed to the method.


7. Growing your Test Suite

Purpose:
* Figure out what's the right process to grow a test suite.
* The most important tests are those that involve features working together.

7.1. Suspecting if the test code is insufficient

The first signal is the test code has less lines of code than the production code.

7.2. List all the system does

* assertions / expectations
* describe blocks
* it blocks
* lets (variabes)
* before blocks

7.3. Analyze the interactions between each other

7.3.1 Parent > Child Relationships

* describe + describe (you can do nested)
* it + it  (it breaks when nested)
* lets + lets (it can reference)
* before + before (it can also reference)
* describe + it (OK)
* describe + lets (OK for lets + describe)

7.3.2. Sibling Relationships

* lets + (describe + describe)
* let + before 



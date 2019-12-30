require_relative '../runner'
require 'pry-byebug'

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

describe "describe" do
  describe "nested describe" do
    it "it works even within a nested describe" do
      expect(1+1).to eq 2
    end
  end
end

describe "it" do
  it "nested it shouldn't work" do
    expect do
      it "shouldn't work" do
      end
    end.to raise_error(NameError)
  end
end

describe "let" do
  let(:five) { 5 }
  let(:random) { rand }
  let(:six) {five + 1}

  it "is available inside the tests" do
    expect(five).to eq 5
  end

  it "always returns the same object" do
    expect(random).to eq random
  end

  it "still fails when methods don't exist" do
    expect do
      method_that_doesnt_exit
    end.to raise_error(NameError)
  end

  it "can reference other lets" do
    expect(six).to eq 6
  end

  # the clue when this breaks is that it looks
  # for method_missing, which means it's not
  # being passed to properly
  describe "nested describes" do
    let(:sibling_five) { 5 }
    it "can see lets from the parent describe" do
      expect(five).to eq 5
    end
  end

  describe "sibling describes" do
    it "can't see lets" do
      expect do
        sibling_five
      end.to raise_error(NameError)
    end
  end
end

describe "before" do
  before { @five = 5 }
  before { @six = @five + 1}

  it "runs before" do
    expect(@five).to eq 5
  end

  it "references other befores" do
    expect(@six).to eq 6
  end

  describe "can't see other befores" do
    it "can't see @six" do
      expect do
        @six
      end.to raise_error(NameError)
    end
  end
end

describe "let and before interacting" do
  before { @five = 5 }
  let(:six) { @five + 1 }
  before {@seven = six + 1}

  it "let references before" do
    expect(six).to eq 6
  end

  it "before references let" do
    expect(@seven).to eq 7
  end
end
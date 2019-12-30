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

describe "let" do
  let(:five) { 5 }
  let(:random) { rand }

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
end

describe "before" do
  before { @five = 5 }

  it "runs before" do
    expect(@five).to eq 5
  end
end
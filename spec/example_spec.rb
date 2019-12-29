require_relative '../runner'

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
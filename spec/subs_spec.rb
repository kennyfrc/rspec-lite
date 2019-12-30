require_relative '../runner'

require 'pry-byebug'

class Subscription

end

describe Subscription do
  let(:subscription) do
    stripe_customer = Stripe.new
    stripe_customer.source = "tok_visa"
    Subscription.new(stripe_customer)
  end

  it "knows its plan id" do
    subscription.create("annual")

    expect(subscription.plan_id).to eq "annual"
  end
end
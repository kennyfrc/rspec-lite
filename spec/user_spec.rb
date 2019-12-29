require_relative '../runner'

require 'pry-byebug'
require 'sequel'

Sequel.connect 'postgres://localhost/speclite'

class User < Sequel::Model(:users)
end

describe User do
  def user
    @user ||= User.create(email: 'kenn@askmonolith.com', last_login: Time.new(2019, 12, 29, 17, 22))
  end

  # "this tests against the object"
  it "has attributes" do
    user.to_hash.should == {
      email: 'kenn@askmonolith.com',
      last_login: Time.new(2019, 12, 29, 17, 22)
    }
  end
end
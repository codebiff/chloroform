require 'spec_helper'

describe User do

  before :each do
    User.collection.remove
  end

  it "should create a new user if one doesn't exist" do
    user = User.find_or_create "joe@example.com", "password"
    user.id.should_not be_nil
  end

  it "should return an existing user if already exists" do
    user1 = User.find_or_create "joe@example.com", "password"
    user2 = User.find_or_create "joe@example.com", "password"
    user1.id.should.eql? user2.id
  end

  it "should not create a user if email is invalid" do
    user = User.find_or_create "joe", "password"
    user.should_not be_kind_of User 
  end

  it "should not create a user if no password is given" do
    user = User.find_or_create "joe@example.com", ""
    user.should_not be_kind_of User
  end

  it "should not return a user if exists but password is incorrect" do
    User.find_or_create "joe@example.com", "password"
    user = User.find_or_create "joe@example.com", "incorrect_password"
    user.should_not be_kind_of User
  end

  it "should generate an email verification token" do
    user = User.find_or_create "joe@example.com", "password"
    user.verification_token.should_not be_nil
  end

  it "should not be verified" do
    user = User.find_or_create "joe@example.com", "password"
    user.verified.should_not be_true 
  end

  it "should generate an API key" do
    user = User.find_or_create "joe@example.com", "password"
    user.api_key.should_not be_nil
  end

  it "should be able to create a new verification token" do
    user = User.find_or_create "joe@example.com", "password"
    v1 = user.verification_token
    user.reset_verification
    user.verification_token.should_not.eql? v1
  end

  it "should email a new verification token" do
    user = User.find_or_create "joe@example.com", "password"
    expect { user.reset_verification }.to change(ActionMailer::Base.deliveries, :size).by(1)
  end

  it "should send out a verification email when registering" do
    expect { User.find_or_create "joe@example.com", "password" }.to change(ActionMailer::Base.deliveries, :size).by(1)
  end

end

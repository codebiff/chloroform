require 'spec_helper'

describe User do

  before :each do
    User.collection.remove
    ActionMailer::Base.deliveries.clear
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
    ActionMailer::Base.deliveries.first.body.should include "http://www.example.com/verify?token=#{User.all.first.verification_token}"
  end

  it "should be able to verify an email address" do
    user = User.find_or_create "joe@example.com", "password"
    User.verify user.verification_token
    user.reload
    user.verified.should be_true
  end


  let(:sample) { {"api_key" => "randomapikey", "name" => "Joe Smith", "email" => "joe@example.com", "message" => "This is a sample message"} }

  it "should add a message to a user" do
    user = User.find_or_create "joe@example.com", "password"
    expect {user.submit sample}.to change(user.messages, :count).by(1)
    JSON.parse(user.messages.first.data).has_key?("name").should be_true
  end

  it "should not submit the api_key to the model" do
    user = User.find_or_create "joe@example.com", "password"
    user.submit sample
    JSON.parse(user.messages.first.data).has_key?("api_key").should be_false
  end

  it "should not submit :action to the model" do
    user = User.find_or_create "joe@example.com", "password"
    user.submit sample
    JSON.parse(user.messages.first.data).has_key?("action").should be_false
  end

  it "should not submit :controller to the model" do
    user = User.find_or_create "joe@example.com", "password"
    user.submit sample
    JSON.parse(user.messages.first.data).has_key?("controller").should be_false
  end

  it "should return a user via the api key" do
    user = User.find_or_create "joe@example.com", "password"
    api_user = User.api_login user.api_key
    api_user.id.should.eql? user.id
  end

  it "should not return a user if api_key is invalid" do
    api_user = User.api_login "bullshit_api_key"
    api_user.should be_false
  end

  it "should redirect to referer url if no confirm url param" do
    user = User.find_or_create "joe@example.com", "password"
    user.submit sample, "http://example.com"
    user.messages.first.confirm_url.should_not be_nil
  end

  it "should redirect to referer url with confirm url param" do
    user = User.find_or_create "joe@example.com", "password"
    user.submit sample.merge({"confirm_url" => "http://another-example.com"}), "http://example.com"
    user.messages.first.confirm_url.should eql "http://another-example.com"
  end

  it "should not submit :confirm_url in the model" do
    user = User.find_or_create "joe@example.com", "password"
    user.submit sample.merge({"confirm_url" => "http://removed-from-data.com"}), "http://example.com"
    JSON.parse(user.messages.first.data).has_key?("confirm_url").should be_false
  end

  context "Settings" do

    it "should have a default date_format setting" do
      user = User.find_or_create "joe@example.com", "password"
      user.config.date_format.should_not be_nil 
      Time.new(1981,06,25,06,05,24).strftime(user.config.date_format).should eq("25/06/1981")
    end

    it "should have a default date_format setting" do
      user = User.find_or_create "joe@example.com", "password"
      user.config.confirm_url.should be_nil 
    end
  end
end

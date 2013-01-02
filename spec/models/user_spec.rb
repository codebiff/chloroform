require 'spec_helper'

describe User do

  before :each do
    User.collection.remove
    ActionMailer::Base.deliveries.clear
  end

  let(:user) { User.find_or_create "joe@example.com", "password" }

  it "should create a new user if one doesn't exist" do
    user.id.should_not be_nil
  end

  it "should return an existing user if already exists" do
    user2 = User.find_or_create "joe@example.com", "password"
    user.id.should.eql? user2.id
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
    User.find_or_create "joe_another@example.com", "password"
    user2 = User.find_or_create "joe_another@example.com", "incorrect_password"
    user2.should_not be_kind_of User
  end

  it "should generate an email verification token" do
    user.verification_token.should_not be_nil
  end

  it "should not be verified" do
    user.verified.should_not be_true 
  end

  it "should generate an API key" do
    user.api_key.should_not be_nil
  end

  it "should be able to create a new verification token" do
    v1 = user.verification_token
    user.reset_verification
    user.verification_token.should_not.eql? v1
  end

  it "should email a new verification token" do
    ActionMailer::Base.deliveries.clear
    expect { user.reset_verification }.to change(ActionMailer::Base.deliveries, :size)
  end

  it "should send out a verification email when registering" do
    expect { User.find_or_create "joe@example.com", "password" }.to change(ActionMailer::Base.deliveries, :size).by(1)
    ActionMailer::Base.deliveries.first.body.should include "http://www.example.com/verify?token=#{User.all.first.verification_token}"
  end

  it "should be able to verify an email address" do
    User.verify user.verification_token
    user.reload
    user.verified.should be_true
  end


  let(:sample) { {"api_key" => "randomapikey", "name" => "Joe Smith", "email" => "joe@example.com", "message" => "This is a sample message"} }

  it "should add a message to a user" do
    expect {user.submit sample}.to change(user.messages, :count).by(1)
    JSON.parse(user.messages.first.data).has_key?("name").should be_true
  end

  it "should not submit the api_key to the model" do
    user.submit sample
    JSON.parse(user.messages.first.data).has_key?("api_key").should be_false
  end

  it "should not submit :action to the model" do
    user.submit sample
    JSON.parse(user.messages.first.data).has_key?("action").should be_false
  end

  it "should not submit :controller to the model" do
    user.submit sample
    JSON.parse(user.messages.first.data).has_key?("controller").should be_false
  end

  it "should return a user via the api key" do
    api_user = User.find_by_api_key user.api_key
    api_user.id.should.eql? user.id
  end

  it "should not return a user if api_key is invalid" do
    api_user = User.find_by_api_key "bullshit_api_key"
    api_user.should be_false
  end

  it "should redirect to referer url if no confirm url param" do
    user.submit sample, "http://example.com"
    user.messages.first.confirm_url.should_not be_nil
  end

  it "should redirect to referer url with confirm url param" do
    user.submit sample.merge({"confirm_url" => "http://another-example.com"}), "http://example.com"
    user.messages.first.confirm_url.should eql "http://another-example.com"
  end

  it "should redirect to config.confirm_url when phen present" do
    user.settings.first.confirm_url = "http://config-set-confirm.com"
    user.save
    user.submit sample, "http://example.com"
    user.reload.messages.first.confirm_url.should eql "http://config-set-confirm.com"
  end

  it "should redirect to confirm url even if config.confirm_url present" do
    user.settings.first.confirm_url = "http://config-set-confirm.com"
    user.save
    user.submit sample.merge({"confirm_url" => "http://another-example.com"}), "http://example.com"
    user.reload.messages.first.confirm_url.should eql "http://another-example.com"
  end

  it "should not submit :confirm_url in the model" do
    user.submit sample.merge({"confirm_url" => "http://removed-from-data.com"}), "http://example.com"
    JSON.parse(user.messages.first.data).has_key?("confirm_url").should be_false
  end

  it "should not submit any params that start with an underscore" do
    user.submit sample.merge({"_hideme" => "i hope i am not entered"}), "http://example.com"
    JSON.parse(user.messages.first.data).has_key?("_hideme").should be_false
  end

  it "should mark a new massage as unread" do
    user.submit sample
    user.messages.first.read.should be_false 
  end

  it "should be ableto toggle a mesages read status" do
    user.submit sample
    user.messages.first.read.should be_false 
    message_id = user.messages.first.id.to_s
    user.toggle_read message_id
    user.reload.messages.first.read.should be_true 
    user.toggle_read message_id
    user.reload.messages.first.read.should be_false
  end


  context "Settings" do

    it "should have a default date_format setting" do
      user.config.date_format.should_not be_nil 
      Time.new(1981,06,25,06,05,24).strftime(user.config.date_format).should eq("25/06/1981")
    end

    it "should have a default date_format setting" do
      user.config.confirm_url.should be_nil 
    end

    it "can update the settings from params" do
      user.update_settings({"confirm_url" => "specialbrew.com", "date_format" => "%m/%d/%y"})
      user.reload.config.confirm_url.should eq("specialbrew.com")
      user.config.date_format.should eq("%m/%d/%y")
    end

    it "should not set an attribute that doesn't exist" do
      user.update_settings({"confirm_url" => "specialbrew.com", "date_format" => "%m/%d/%y", "not_in_model" => "Something aweful"})
      user.reload.config.keys.keys.should_not include("not_in_model")
    end

    it "should be able to toggle a message as read or not" do
      
    end

  end
end

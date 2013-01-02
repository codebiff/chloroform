require 'spec_helper'

describe ApiController do

  before :each do
    User.collection.remove
  end

  describe "POST 'submit'" do

    it "should add form data to the user messages if api_token valid" do
      user = User.find_or_create "joe@example.com", "password"
      post :submit, {:api_key => user.api_key, :field_one => "Some text", :confirm_url => "http://google.com"}
      JSON.parse(user.reload.messages.first.data).has_key?("field_one").should be_true
    end

    it "should fail if api_key is incorrect" do
      post :submit, {:api_key => "wrong_api_key", :field_one => "Some text"}
      response.should_not be_ok
    end

    it "should not create a message if no data is submitted" do
      user = User.find_or_create "joe@example.com", "password"
      post :submit, {:api_key => user.api_key}
      response.should_not be_ok
      user.reload.messages.count.should == 0
    end

  end

end

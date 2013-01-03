require "spec_helper"

describe "Users" do

  def clear_db
    User.collection.remove
  end

  context "with valid credentials" do

    it "should login and redirect to the account page" do
      clear_db
      visit root_path
      expect {
        fill_in "email",    with: "joe@example.com"
        fill_in "password", with: "password"
        click_button "Login"
      }.to change(User, :count).by(1)
      page.should have_content "joe@example.com"
    end

  end

  context "with invalid credentials" do

    it "no password should not login and redirect back to index" do
      clear_db
      visit root_path
      fill_in "email", with: "joe@example.com"
      click_button "Login"
      page.should have_selector "form"
      page.should have_content "A password is required"
    end

    it "incorrect password for user should redirect to index" do
      clear_db
      User.find_or_create "joe@example.com", "password"
      visit root_path
      fill_in "email", with: "joe@example.com"
      fill_in "password", with: "wrong_password"
      click_button "Login"
      page.should have_selector "form"
      page.should have_content "The password was incorrect"
    end

    it "an invalid email is used" do
      clear_db
      visit root_path
      fill_in "email", with: "joe_invalid_example.com"
      fill_in "password", with: "password"
      click_button "Login"
      page.should have_selector "form"
      page.should have_content "Please enter a valid email address"
    end

  end

  context "account page" do

    it "should logout via the logout link" do
      visit root_path
      fill_in "email", with: "joe@example.com"
      fill_in "password", with: "password"
      click_button "Login"
      page.should have_content "logout"
      click_link "logout"
      page.should have_selector "form"
    end

    it "should redirect to the index page if not logged in" do
      clear_db
      visit logout_path
      visit account_path
      page.should have_selector "form"
      page.should have_content "Please login or register to view that page"
    end

    it "should reset verification when button pressed" do
      visit root_path
      fill_in "email", with: "joe@example.com"
      fill_in "password", with: "password"
      click_button "Login"
      click_link "Request a new verification email"
      page.should have_content "A new verification email has been sent"
    end

    it "should redirect to account page if already logged in" do
      pending "waiting for Capybara to recognize title"
      clear_db
      visit root_path
      fill_in "email", with: "joe@example.com"
      fill_in "password", with: "password"
      click_button "Login"
      visit root_path
      find("title").should have_content "Account"
    end

    it "should display messages if present" do
      clear_db
      visit root_path
      fill_in "email", with: "joe@example.com"
      fill_in "password", with: "password"
      click_button "Login"
      user = User.all.first
      user.submit :params => {:api_key => user.api_key, :field_one => "Some sample data", :field_two => "Some more data"} 
      visit account_path
      page.should have_content "Some sample data"
    end

    it "should delete a message from the page" do
      clear_db
      visit root_path
      fill_in "email", with: "joe@example.com"
      fill_in "password", with: "password"
      click_button "Login"
      user = User.all.first
      5.times { user.submit :params => {:api_key => user.api_key, :field_one => "Some sample data", :field_two => "Some more data"} }
      visit account_path
      page.should have_css("table.message", :count => 5)
      within("table.message:first-of-type") { click_link "Delete this message" }
      page.should have_css("table.message", :count => 4)
    end

    it "should mark as message as read" do
      clear_db
      visit root_path
      fill_in "email", with: "joe@example.com"
      fill_in "password", with: "password"
      click_button "Login"
      user = User.all.first
      5.times { user.submit :params => {:api_key => user.api_key, :field_one => "Some sample data", :field_two => "Some more data"} }
      visit account_path
      page.should have_css("table.message", :count => 5)
      within("table.message:first-of-type") { click_link "Mark as read" }
      page.should have_css("table.message", :count => 4)
      visit messages_path
      within("table.message:first-of-type") { click_link "Mark as unread"}
      visit account_path
      page.should have_css("table.message", :count => 5)
    end

    it "should be able to delete all messages" do
      clear_db
      visit root_path
      fill_in "email", with: "joe@example.com"
      fill_in "password", with: "password"
      click_button "Login"
      user = User.all.first
      5.times { user.submit :params => {:api_key => user.api_key, :field_one => "Some sample data", :field_two => "Some more data"} }
      visit messages_path
      page.should have_css("table.message", :count => 5)
      click_link "Delete all"
      page.should_not have_css("table.message")
    end

  end


  describe "GET 'verify'" do
    it "should verify an email address if valid" do
      user = User.find_or_create "joe@example.com", "password"
      visit "/verify?token=#{user.verification_token}"
      page.should have_content "verifying your email"
    end  

    it "should send an error if unknown token sent" do
      visit "/verify?token=mumbo_jumbo"
      page.should have_content "problem with your verification token"
    end

    it "should send an error if no token is present" do
      visit "/verify"
      page.should have_content "problem with your verification token"
    end

    it "should not log you out if something is submitted" do
      clear_db
      visit root_path
      fill_in "email", with: "joe@example.com"
      fill_in "password", with: "password"
      click_button "Login"
      user = User.all.first
      post "/api/submit?api_key=#{user.api_key}&name=joe_example&confirm_url=http://google.com"
      visit account_path
      page.should have_content "Unread Messages"
    end

  end

  describe "GET 'settings'" do
    it "shouldn't have a confirm_url if none entered into config" do
      clear_db
      visit root_path
      fill_in "email", with: "joe@example.com"
      fill_in "password", with: "password"
      click_button "Login"
      visit settings_path
      find_field("confirm_url").value.should be_nil
    end

    it "should have a confirm_url if one entered into config" do
      clear_db
      visit root_path
      fill_in "email", with: "joe@example.com"
      fill_in "password", with: "password"
      click_button "Login"
      user = User.all.first
      user.settings.first.confirm_url = "http://example.com"
      user.save
      visit settings_path
      find_field("confirm_url").value.should eql("http://example.com")
    end

    it "should redirect to the index page if not logged in" do
      clear_db
      visit logout_path
      visit settings_path
      page.should have_selector "form"
      page.should have_content "Please login or register to view that page"
    end

    it "should update settings when form submitted" do
      clear_db
      visit root_path
      fill_in "email", with: "joe@example.com"
      fill_in "password", with: "password"
      click_button "Login"
      visit settings_path
      fill_in "confirm_url", with: "http://example.com"
      click_button "Save Changes"
      User.all.first.config.confirm_url.should eq("http://example.com")
      page.should have_content "Settings have been updated"
    end
  end

end

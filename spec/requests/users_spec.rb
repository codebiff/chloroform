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
      pending
      clear_db
      visit root_path
      fill_in "email", with: "joe@example.com"
      fill_in "password", with: "password"
      click_button "Login"
      visit root_path
      find("title").should have_content "Account"
    end


  end

end

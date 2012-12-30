require "spec_helper"

describe "Users" do

  def clear_db
    User.collection.remove
  end

  context "with valid credentials" do

    it "should login and redirect to the account page" do
      clear_db
      visit user_index_path
      expect {
        fill_in "email",    with: "joe@example.com"
        fill_in "password", with: "password"
        click_button "Login"
      }.to change(User, :count).by(1)
      page.should have_content "joe@example.com"
    end

  end

  context "with invalid credentials"
end

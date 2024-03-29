require 'spec_helper'

describe UserController do

  def clear_db
    User.collection.remove
  end

  let(:user) { User.all.first }

  describe "GET 'index'" do
    it "returns http success" do
      get 'index'
      response.should be_success
    end

    it "should redirect to accounts page if already logged in" do
      post :login, :email => "joe@example.com", :password => "password"
      get 'index'
      response.should redirect_to account_path
    end
      
  end

  describe "POST 'login'" do
    context "with valid credentials" do

      it "should create a new user" do
        clear_db
        expect{ post :login, :email => "joe@example.com", :password => "password" }.to change(User, :count).by(1)
      end

      it "should login with existing details if already registered" do
        expect{ post :login, :email => "joe@example.com", :password => "password" }.to_not change(User, :count)
      end

      it "should redirect to the accounts page" do
        post :login, :email => "joe@example.com", :password => "password"
        response.should redirect_to account_path
      end

      it "should set the user session" do
        post :login, :email => "joe@example.com", :password => "password"
        session[:user].should_not be_nil
      end
    end

    context "with invalid credentials" do
      
      it "should not create a new user" do
        clear_db
        expect{ post :login, :email => "joe@example.com", :password => "" }.to_not change(User, :count)
      end

      it "should redirect to the index page" do
        post :login, :email => "joe@example.com", :password => ""
        response.should redirect_to root_path
      end

    end
  end

  describe "GET 'logout'" do
    
    it "should redirect to the index" do
      get :logout
      response.should redirect_to root_path
    end

    it "should clear out the user session" do
      get :logout
      session[:user].should be_nil
    end

  end


  describe "GET 'account'" do

    it "should redirect you back to index if not logged in" do
      get :logout
      get :account
      response.should redirect_to root_path
    end

    it "should display correctly if a user is logged in" do
      post :login, :email => "joe@example.com", :password => "password"
      get :account
      response.should be_ok      
    end


  end

  describe "GET 'reset_verification'" do
    it "should return the user to the accounts page" do
      post :login, :email => "joe@example.com", :password => "password"
      get :reset_verification
      response.should redirect_to account_path
    end
  end

  describe "GET 'verify'" do
    it "should verify a user if valid" do
      clear_db
      post :login, :email => "joe@example.com", :password => "password"
      get :verify, :token => user.verification_token
      user.reload.verified.should be_true
      response.should redirect_to account_path
    end

    it "should return an error if invalid" do
      clear_db
      post :login, :email => "joe@example.com", :password => "password"
      get :verify, :token => "invalid_token"
      response.should redirect_to account_path
    end
  end

  describe "POST 'settings'" do
    it "should update user settings" do
      clear_db
      post :login, :email => "joe@example.com", :password => "password"
      post :save_settings, {"confirm_url" => "http://example.com"}
      user.config.confirm_url.should eq("http://example.com")
    end
  end

  describe "GET 'admin" do

    it "should not allow access if user is not admin" do
      clear_db
      post :login, :email => "joe@example.com", :password => "password"
      get :admin
      response.should be_redirect
    end

    it "should allow access if user is admin" do
      clear_db
      post :login, :email => "joe@example.com", :password => "password"
      User.all.first.update_attribute(:admin, true)
      get :admin
      response.should_not be_redirect
    end
    
  end

end

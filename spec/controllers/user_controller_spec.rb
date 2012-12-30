require 'spec_helper'

describe UserController do

  def clear_db
    User.collection.remove
  end

  describe "GET 'index'" do
    it "returns http success" do
      get 'index'
      response.should be_success
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
        response.should redirect_to user_account_path
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
        response.should redirect_to user_index_path
      end

    end
  end

  describe "GET 'logout'" do
    
    it "should redirect to the index" do
      get :logout
      response.should redirect_to user_index_path
    end

  end


  describe "GET 'account'" do

    it "should redirect you back to index if not logged in" do
      get :account
      response.should redirect_to user_index_path
    end

    it "should display correctly if a user is logged in" do
      post :login, :email => "joe@example.com", :password => "password"
      get :account
      response.should be_ok      
    end


  end

end

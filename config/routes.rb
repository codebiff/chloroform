Chloroform::Application.routes.draw do

  root :to => "user#index" 

  match "login" => "user#login"
  match "logout" => "user#logout"
  match "account" => "user#account"
  match "settings" => "user#settings"
  match "save_settings" => "user#save_settings"

  match "verify" => "user#verify"
  match "reset_verification" => "user#reset_verification"

  post "api/submit"
  get "message/delete"

end

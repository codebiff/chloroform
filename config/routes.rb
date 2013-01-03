Chloroform::Application.routes.draw do

  root :to => "user#index" 

  match "login" => "user#login"
  match "logout" => "user#logout"
  match "account" => "user#account"
  match "settings" => "user#settings"
  match "save_settings" => "user#save_settings"
  match "help" => "user#help"

  match "messages" => "message#index"

  match "verify" => "user#verify"
  match "reset_verification" => "user#reset_verification"

  post "api/submit"
  get "message/delete"
  get "message/toggle_read"
  get "message/toggle_all_read"
  get "message/delete_all"

end

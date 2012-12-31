class UserMailer < ActionMailer::Base
  default from: "no-reply@codebiff.com"

  def register user
    @user = user
    mail(:to => user.email, :subject => "Thank you for registering with Choloroform")
  end

  def reset_verification user
    @user = user
    mail(:to => user.email, :subject => "Chloroform - Reset verification email")
  end
end

class AdminMailer < ActionMailer::Base
  default from: "no-reply@codebiff.com"

  def new_registration user_email
    @email = user_email
    mail(to: "dave@codebiff.com", subject: "Chloroform - A new user has registered!")
  end

end

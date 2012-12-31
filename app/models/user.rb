require "bcrypt"

class User
  include MongoMapper::Document

  key :email,            String, :format => /@./
  key :password_salt,    String
  key :password_hash,    String
  key :verification_token, String
  key :verified,         Boolean, :default => false
  key :api_key,          String

  def self.find_or_create email, password
    if user = User.find_by_email(email.strip)
      if user.password_hash == BCrypt::Engine.hash_secret(password, user.password_salt)
        user
      else
        "The password was incorrect" 
      end
    else
      return "A password is required" if password.empty?
      u = User.new
      u.email = email.strip
      u.password_salt = BCrypt::Engine.generate_salt
      u.password_hash = BCrypt::Engine.hash_secret(password, u.password_salt)
      u.verification_token = SecureRandom.hex
      u.api_key = SecureRandom.hex
      return "Please enter a valid email address" unless u.save
      UserMailer.register(u).deliver
      u
    end
  end

  def reset_verification
    verification_token = SecureRandom.hex
    save
    UserMailer.reset_verification(self).deliver
  end

  def self.verify token
    if u = User.find_by_verification_token(token)
      u.verified = true
      u.save
    else
      false
    end
  end

end

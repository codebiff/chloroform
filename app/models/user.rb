require "bcrypt"

class User
  include MongoMapper::Document

  key :email,         String, :format => /@./
  key :password_salt, String
  key :password_hash, String

  def self.find_or_create email, password
    if user = User.find_by_email(email.strip)
      if user.password_hash == BCrypt::Engine.hash_secret(password, user.password_salt)
        user
      else
        false 
      end
    else
      return false if password.empty?
      u = User.new
      u.email = email.strip
      u.password_salt = BCrypt::Engine.generate_salt
      u.password_hash = BCrypt::Engine.hash_secret(password, u.password_salt)
      return false unless u.save
      u
    end
  end

end

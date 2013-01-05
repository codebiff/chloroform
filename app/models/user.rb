require "bcrypt"

class User
  include MongoMapper::Document

  key :email,              String,  :format => /@./
  key :password_salt,      String
  key :password_hash,      String
  key :verification_token, String
  key :verified,           Boolean, :default => false
  key :api_key,            String

  many :settings
  many :messages

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
      u.settings.push Setting.new
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

  def submit params, referer=nil
    m = Message.new
    m.confirm_url = parse_confirm_url(params, referer)
    fields = clean_params(params).to_json
    return false if JSON.parse(fields).empty?
    m.data = fields
    messages.push m
    if save
      if verified
        UserMailer.send_message(self).deliver
      end
      return messages.last
    else
      return false
    end
  end

  def clean_params params
    cleaned = params.reject {|k,v| ["api_key", "action", "controller", "confirm_url"].include? k.to_s}
    cleaned = cleaned.reject {|k,v| k.to_s[0] == "_"}
    cleaned
  end

  def parse_confirm_url params, referer
    return params["confirm_url"] if params.has_key?("confirm_url")
    return config.confirm_url || referer
  end

  def toggle_read message_id
    message = messages.select {|m| m.id.to_s == message_id}.first
    message.read = toggle(message.read)
    save
  end

  def config
    settings.first
  end

  def update_settings params
    params.each {|k,v| config.update_attributes(k.to_sym => v) if config.keys.keys.include?(k)}
    save
  end

  def toggle param
    param ? false : true    
  end

  def reset_api
    self.api_key = SecureRandom.hex
    save
  end

end

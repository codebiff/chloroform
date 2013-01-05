class Message
  include MongoMapper::EmbeddedDocument

  key :confirm_url, String
  key :read,        Boolean, :default => false
  key :data,        String

  timestamps!

end

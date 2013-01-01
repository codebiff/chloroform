class Message
  include MongoMapper::EmbeddedDocument

  key :confirm_url, String
  key :data, String

  timestamps!

end

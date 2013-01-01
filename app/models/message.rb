class Message
  include MongoMapper::EmbeddedDocument

  key :data, String

  timestamps!

end

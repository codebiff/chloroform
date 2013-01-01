class Setting
  include MongoMapper::EmbeddedDocument

  key :date_format, String, :default => "%d/%m/%Y"
  key :confirm_url, String

end

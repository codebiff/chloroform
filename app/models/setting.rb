class Setting
  include MongoMapper::EmbeddedDocument

  key :date_format, String, :default => "%d/%m/%Y"
  key :time_format, String, :default => "%H:%M"
  key :confirm_url, String

end

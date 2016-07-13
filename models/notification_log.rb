class NotificationLog
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial
  property :school_id, Integer
  property :role, Integer
  property :role_id, Integer
  property :content, String
  property :created_at, DateTime
end

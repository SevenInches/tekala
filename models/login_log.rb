class LoginLog
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial
  property :device_no, String
  property :school_id, Integer
  property :user_id, Integer
  property :login_type, Integer
  property :result, Boolean
  property :created_at, DateTime
end

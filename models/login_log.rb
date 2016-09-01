class LoginLog
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial
  property :device_no, String
  property :school_id, Integer
  property :user_id, Integer
  #登录类型,1=>微信,2=>账号
  property :login_type, Integer
  property :result, Boolean, :default => true
  property :created_at, DateTime
end

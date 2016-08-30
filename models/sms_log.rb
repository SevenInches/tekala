#短信日志
class SmsLog
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial
  property :created_at, DateTime
  property :updated_at, DateTime
  property :school_id, Integer
  property :content, String
  property :status, Integer
  property :receiver, String
  property :mobile, String
end

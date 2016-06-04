class SmsRecord
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial
  property :content, Text
  property :to_user, String
  property :to_mobile, String
  property :type, String
  property :order_id, Integer
  property :created_at, DateTime

  def created_at_format 
  	created_at.strftime('%Y-%m-%d %H:%M:%S')
  end
end

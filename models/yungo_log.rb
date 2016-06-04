class YungoLog
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial
  property :user_id, Integer
  property :order_id, Integer
  property :yungo_id, Integer
  property :code, Integer
  property :time_num, Integer
  property :created_at, DateTime
  property :wechat_avatar, String
  property :wechat_openid, String
  property :wechat_unionid, String
  belongs_to :order, :model => 'Order'
  belongs_to :user,  :model => 'User'
end

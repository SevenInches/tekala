class UserComment
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial
  property :teacher_id, Integer
  property :user_id, Integer
  property :rate, Integer
  property :content, Text
  property :created_at, DateTime

  #一个订单一条评论
  property :order_id, Integer

  belongs_to :user
  belongs_to :teacher

  
  def created_format
    created_at.strftime('%Y-%m-%d')
  end

end

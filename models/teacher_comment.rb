#教练得到的评价
class TeacherComment
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial
  property :user_id, Integer
  property :teacher_id, Integer
  property :rate, Integer, :default => 5
  property :content, Text, :lazy => false 
  property :created_at, DateTime

  #一个订单一条评论
  property :order_id, Integer

  belongs_to :user
  belongs_to :teacher

  def created_format
    created_at.strftime('%Y-%m-%d %H:%M')
  end
end

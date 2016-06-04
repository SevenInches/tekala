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

  has n, :photos, :model => 'CommentPhoto', :child_key =>'comment_id' , :constraint => :destroy
  
  after :save do 
    #评论后填充结算时间
    order         = Order.get order_id
    current_wday  = Date.today.wday
    sum_date      = Date.today + (9 - current_wday).days
    order.sum_time = sum_date
    order.save

    # 小于4分的意见反馈，发送警报 
    if rate < 4
      OptMessage.create(:title=>'教练评价', :content=>"差评 | #{content}", :receiver=>:admin)
    end
  end

  def created_format
    created_at.strftime('%Y-%m-%d %H:%M')
  end

  def rate_color
    case 
    when self.rate < 4
      return 'danger'
    else
    return 'success'
    end
  end
end

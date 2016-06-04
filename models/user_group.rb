class UserGroup
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial
  property :group_id, Integer
  property :user_id, Integer
  property :user_name, String
  property :user_mobile, String
  property :wechat_avatar, String
  property :wechat_unionid, String
  property :order_id, Integer
  property :created_at, DateTime
  property :is_sms, Integer, :default => 0

  belongs_to :user, :model => 'User'
  belongs_to :group, :model => 'Group'

  belongs_to :order

  def has_paid
    # pay_money = group.discount
    # user.orders.first(:price => pay_money, :status => Order::pay_or_done).nil?
    (order && Order::pay_or_done.include?(order.status)) ? true : false
  end

  def join_count
    UserGroup.all(:group_id => group_id).count
  end

  def group_price
    group ? group.price : 0
  end

  def group_count
    group ? group.count : 0
  end

  def paid_count
    ug = UserGroup.all(:group_id => group_id)
    count = 0 
    ug.each do |current_ug|
      count += 1 if current_ug.has_paid
    end
    count
  end

  def created_at_format 
    created_at.strftime("%m月%d日 %H:%M")
  end
end

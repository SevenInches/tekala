class UserCoupon
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial
  property :coupon_id, Integer
  property :order_id, Integer
  property :user_id, Integer
  property :status, Integer, :default => 1
  property :code, String
  property :updated_at, DateTime
  property :created_at, DateTime

  belongs_to :user, :model => 'User', :child_key => 'user_id'  
  belongs_to :coupon, :model => 'Coupon', :child_key => 'coupon_id'

  belongs_to :order, :model => "Order", :child_key => 'order_id'

  after :create, :decrease_coupon_count

  after :save, :set_discount

  def set_discount 

    if !order_id.nil?
      order.discount = coupon.money
      order.save
      
    end
  end

  #新增后将优惠券数量减一
  def decrease_coupon_count
    coupon = Coupon.get coupon_id
    coupon.count -= 1 if coupon && coupon.count > 0
    coupon.save
  end

  #使用后将使用优惠券数量加一
  def decrease_coupon_usecount
    coupon = Coupon.get coupon_id
    coupon.use_count += 1 if coupon
    coupon.save
  end

  def money
    coupon.money
  end

  def available
    
    return 301  if coupon.start_at > Time.now 
    return 302  if coupon.end_at   < Time.now 
    return 303  if status < 1
    return 200
  end

  def available_word
    if available == 200
      '可用'
    else
      '不可用'
    end
  end
  
end

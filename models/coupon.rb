class Coupon
  include DataMapper::Resource

  property :id, Serial
  property :money, Integer, :required => true
  property :start_at, DateTime
  property :end_at, DateTime
  property :city_id, Integer, :required => false
  property :count, Integer, :required => true, :default => 9999
  property :use_count, Integer, :required => true, :default => 0
 
  property :created_at, DateTime
  property :updated_at, DateTime
  
  has n, :user_coupons

  def coupon_status 
    return 303 if  use_count >= count  #领取完
    return 302 if  end_at < Time.now   #已过期
    return 200  #可领取状态
  end

  def coupon_status_word
    case coupon_status
    when 200
      '可用'
    else
      '不可用'
    end
  end

  def added user_id
    return UserCoupon.first(:coupon_id => id, :user_id => user_id ) ? true : false
  end

  def start_format 
    start_at.strftime('%Y-%m-%d')
  end

  def end_format
    end_at.strftime('%Y-%m-%d')
  end

  def created_format
    created_at.strftime('%Y-%m-%d')
  end
  def updated_format
    updated_at.strftime('%Y-%m-%d')
  end
  
end

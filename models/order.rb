class Order
  include DataMapper::Resource
  attr_accessor :no_jpush
  #before_status after save 保存之前的状态
  attr_accessor :before_status

  #VIP订单 1 普通订单 0,2 需要支付给教练 0, 无需支付给教练 2
  VIPTYPE       = 1
  NORMALTYPE    = [1,2]
  PAYTOTEACHER  = 1
  FREETOTEACHER = 2

  STATUS_CANCEL     = 7   # 取消状态
  STATUS_REFUNDING  = 5   # 退款中
  #补贴

  C2_ALLOWANCE = 10

  #收佣金
  REBATE       = 0.1

  property :id, Serial
  property :user_id, Integer
  property :teacher_id, Integer
  property :train_field_id, Integer
  property :school_id, Integer
  property :city_id, Integer
  property :order_no, String
  property :amount, Float
  property :discount, Float, :default => 0.0
  property :subject, Text, :lazy => false, :default => ''
  property :quantity, Integer #学时数量
  property :price, Float #单价
  property :note, String, :default => ''
  property :device, String, :default => ''

  property :pay_at,     DateTime
  property :done_at,    DateTime
  property :cancel_at,  DateTime
  property :created_at, DateTime
  property :updated_at, DateTime
  property :book_time,  DateTime  #预订时间

  #是否已经买了保单
  property :has_insure, Integer, :default => 0
  
  property :confirm, Integer, :default => 0 #教练或者后台是否已经确定处理该订单 0未处理
  
  property :ch_id, String #ping++ ch_id


  #'未支付'=>1, '已支付'=>2, '已完成'=>3, '已确定'=>4, '退款中' => 5, '已退款' => 6, '取消'=>7
  property :status, Integer, :default => 1

  #'练车预约订单' => 1, '打包订单' => 2, '活动预付款' => 3
  property :type, Integer, :default => 1 #2 为无需记录学时

  #'C1' => 1, 'C2' => 2
  property :exam_type, Integer, :default => 1 #学车类型

  #'普通订单' => 1, '会员的订单' =>2
  property :vip, Integer, :default => 1

  property :remark, String

  # mok 经纬度 2015-09-07
  property :latitude, String
  property :longitude, String

  property :has_sms, Integer, :default => 0

  #mok 产品id号 2015-09-30
  property :product_id, Integer, :default => 0
  property :city_id, Integer

  property :theme, String

  #结算时间
  property :sum_time, DateTime

  property :pay_channel, String

  belongs_to :user
  belongs_to :teacher
  belongs_to :train_field
  belongs_to :product, :model => 'Product'
  belongs_to :school
  belongs_to :city

  has 1, :user_coupon
  has 1, :teacher_comment
  has 1, :user_comment

  #教练接单
  has 1, :order_confirm, :constraint => :destroy

  has 1, :insure

  after :create do |order|
    if order.status == 2 && Order::should_record_hours.include?(type)
      user_plan_increase
      learn_hours_increase 
      teacher_tech_increase
      create_user_schedule
    end
  end
  
  before :save do |order|
    #判断order的类型
      o = Order.get order.id
      self.before_status = o ? o.status : nil 
  end
 
  after :save do  

    if !self.before_status.nil?
      #完成订单记录时间
      if self.before_status < 103 && status == 103
        self.update(:done_at => Time.now)
      end

      #更新学车计划 统计学车时间 订单支付 +1 (测试通过) 
      if self.before_status < 1 && status == 2 &&  Order::should_record_hours.include?(type)
        user_plan_increase
        learn_hours_increase 
        teacher_tech_increase if type == 0 #如果非绑定教练的话 才给教练+1
      end

      #订单取消或者退款 则学时数 -1 (测试通过)
      if Order::pay_or_done.include?(self.before_status) && (status == 6 || status == 6) &&  Order::should_record_hours.include?(type)
        # user_plan_decrease
        # learn_hours_decrease 
        # teacher_tech_decrease if type == 0 #如果非绑定教练的话 才给教练-1
      end

      #生成学车进度 && 推送给教练 (通过测试)
      if self.before_status < 2 && status == 2 && Order::should_record_hours.include?(type)
        create_user_schedule
      end

    end
  end

  #更新学车计划 统计学车时间 订单支付 +1
  def user_plan_increase 
    plan = user.user_plan
    plan.exam_two   += quantity if user.status_flag < 7
    plan.exam_three += quantity if user.status_flag > 6
    plan.save
  end

  #订单取消或者退款 则学时数 -1
  def user_plan_decrease
    plan = user.user_plan

    # 若已经开始练科目三学时，则退科目三，否则退科目二
    if plan.exam_three > 0
      plan.exam_three -= quantity
    else
      plan.exam_two   -= quantity
    end

    plan.save
  end
    
  #推送给教练 是否接单
  def push_to_teacher
    #预订的日期
    if status == 2 && Order::should_record_hours.include?(type)
      current_confirm = OrderConfirm.create(:order_id   => id,
                                            :user_id    => user_id, 
                                            :teacher_id => teacher_id, 
                                            :user_id    => user_id,
                                            :start_at   => book_time,
                                            :end_at     => book_time + quantity.hour,
                                            :status     => 0)
      #如果是订单教练为内部员工 测试 则不发送推送
      JPush::order_confirm(current_confirm.order_id) if teacher_id != 477
    end

  end

  # 判断是否可退款
  def can_refund?
    ([2,3,4].include? status) && pay_at != nil
  end

  #统计来源 状态为支付 类型是 4800包过班 通过微信支付渠道
  def update_channel_data

    promotion = PromotionUser.first(:user_id => user_id)
    if promotion && !promotion.wechat_unionid.nil?

      promotion_channel = PromotionChannel.first(:from => promotion.wechat_unionid)
      
      if !promotion_channel.nil?
      
        data = ChannelData.first_or_create(:event_key => promotion_channel.event_key, :date => Date.today.strftime('%Y%m%d'))
        data.pay_count = data.pay_count.to_i + 1
        data.save
      
      end

    end
    
  end

  #统计用户学时
  def learn_hours_increase
    user.learn_hours += quantity
    user.save
  end

  def learn_hours_decrease
    user.learn_hours -= quantity
    user.save
  end


  #更新教练已教学时
  def teacher_tech_increase
    return unless teacher
    teacher.tech_hours += quantity
    teacher.save
  end

  def teacher_tech_decrease
    return unless teacher
    teacher.tech_hours -= quantity
    teacher.save
  end

  #退回代金券
  def return_coupon 

    coupon = UserCoupon.first(:order_id => id)
    if coupon
      coupon.status = 1
      coupon.order_id = nil
      coupon.save
    end

  end
  
  #创建进度记录
  def create_user_schedule
    record = UserSchedule.new
    record.user_id   = user_id
    record.quantity  = quantity
    record.book_time = book_time
    record.theme     = theme
    record.status    = 1
    record.save
  end

  def has_coupon 
    user_coupon ? true : false
  end

  
  def generate_order_no
    year    = Time.now.year
    month   = "%02d" % Time.now.month
    day     = "%02d" % Time.now.day
    hour    = "%02d" % Time.now.hour
    min     = "%02d" % Time.now.min
    sec     = "%02d" % Time.now.sec
    user_id = self.user_id
    rands   = rand(9999)
    self.update(:order_no => "#{year}#{month}#{day}#{hour}#{min}#{sec}#{rands}#{user_id}".to_s)
  end

  def book_time_format
    book_time ? book_time.strftime('%Y-%m-%d %H:%M') : ''
  end


  def self.generate_order_no_h5
    year    = Time.now.year
    month   = "%02d" % Time.now.month
    day     = "%02d" % Time.now.day
    hour    = "%02d" % Time.now.hour
    min     = "%02d" % Time.now.min
    sec     = "%02d" % Time.now.sec
    user_id = self.user_id
    rands   = rand(9999)
    return "#{year}#{month}#{day}#{hour}#{min}#{sec}#{rands}".to_s
  end

  def self.get_status
    return {'未支付'=>'101', '已支付'=>'102', '已确定'=>'104', '已完成'=>'103', '退款中'=>'2', '退款'=>'1', '取消'=>'0'}
  end

  def set_status
    case self.status
    when 101
      return '未支付'
    when 102
      return '已支付'
    when 103
      return '已完成'
    when 104
      return '已确定'
    when 2
      return '退款中'
    when 1
      return '已退款'
    when 0
      return '已取消'
    end
  end

  def status_word
    case self.status
    when 101
      return '待支付'
    when 102
      return '等待接单'
    when 103
      if can_comment && !user_has_comment
       return '待评价'
      else
       return '已完成'
      end
    when 104
      return '已接单'
    when 2
      return '退款中'
    when 1
      return '已退款'
    when 0
      if accept_status == 2
        return '教练繁忙'
      else
        return '已取消'
      end
    end
  end

  def status_color 
    case self.status
    when 101
      return 'danger'
    when 102
      return 'success'
    when 103
      return 'info'
    when 104
      return 'info'
    when 2
      return 'danger'
    when 1
      return 'warning'
    when 0
      return 'warning'
    end

  end

  def device_color
    case self.device.downcase
    when /android/
      return 'primary'
    when /ios/, /iphone/
      return 'info'
    else
      return 'success'
    end
  end

  def device_type
    case self.device.downcase
    when /android/
      return '安卓'
    when /ios/, /iphone/
      return '苹果'
    else
      return '微信'
    end
  end

  def created_at_format
    created_at.strftime('%Y-%m-%d %H:%M')
  end

  def pay_at_format 
   pay_at ? pay_at.strftime('%Y-%m-%d %H:%M') : ''
  end

  def promotion_amount 

    promotion = amount.to_f-discount.to_f
    # promotion += (quantity*1.5) if has_insure == 1
    if promotion > 0
      #self.update(:vip => 0)
      promotion
    else
      #self.update(:vip => 1)
      0
    end 
  end

  def self.type
    {'普通班' => 0, '包过班' => 1}
  end

  def type_word
    case type
    when 1
      '包过班'
    else
      '普通班'
    end
  end

  #是否可评论 status > 101 && 已经练完车 && 未评论过
  def can_comment 
    status > 101 && book_time < Time.now && teacher_comment.nil? 
  end

  def teacher_can_comment 
    return  status == 103 && user_comment.nil? ? true : false
  end

  def user_has_comment 
    !user_comment.nil? 
  end

  def self.has_comment_color(status)
    case status
    when true
      return 'success'
    when false
      return 'warning'
    end
  end
  def train_field_name
    train_field ? train_field.name :  teacher.training_field
  end

  def self.pay_or_done 
    [2,3,4]
  end

  def self.normal_order
    [1,2]
  end

  def self.signup_status
    {'未支付' => 101, '已支付' => 200, '退款中'=>'2', '退款'=>'1', '取消'=>'0'}
  end

  def self.unpay 
    Order.all(:status => 101)
  end

  #是否显示包过班优惠款
  def vip_promotion_money_disply
    user.type == 1 && discount.to_i > 0 && user_coupon.nil?
  end

  #教练是否已经接单
  def accept_status
    return 0 if order_confirm.nil? 
    order_confirm.status 
  end

  def self.city
    return {'深圳' => '0755', '武汉' => '027', '重庆' => '023'}
  end

  def self.city_word(city)
    case city
    when '0755'
      return '深圳'
    when '027'
      return '武汉'
    when '023'
      return '重庆'
    end
  end

  def self.theme 
      {'车辆行驶准备'    => 0,
       '车辆基本操作'    => 1,
       '倒车入库'       => 2,
       '侧方停车'       => 3,
       '坡道停车和起步'  => 4,
       '曲线行驶'       => 5,
       '直角转弯'       => 6,
       '科目三训练项'    => 7}
  end

  def self.theme_api
      [{"name" => '车辆行驶准备', 'code' => 0},
       {"name" => '车辆基本操作', 'code' => 1},
       {"name" => '倒车入库', 'code' => 2},
       {"name" => '侧方停车', 'code' => 3},
       {"name" => '坡道停车和起步', 'code' => 4},
       {"name" => '曲线行驶', 'code' => 5},
       {"name" => '直角转弯', 'code' => 6}]
  end

  def theme_name(code)
    word = ''
    Order::theme_api.each do |theme|
       word = theme['name'] if theme['code'] == code
    end
    word
  end

  def theme_word 
    word_arr = []
    theme ||= ''
    theme_arr = theme.split(',')   
    theme_arr.each do |t|
      word_arr << theme_name(t.to_i) if !t.empty?
    end 

    word_arr
  end

  def self.sort_icon(param)
    case param
    when 'desc'
      return 'sort-desc'
    when 'asc'
      return 'sort-asc'
    else
      return 'sort'
    end
  end

  def pay_channel_label
    case pay_channel
    when 'wx'
      "<label class='label label-success'>微信支付</label>"
    when 'wx_pub'
      "<label class='label label-success'>微信支付</label>"
    when 'alipay'
      "<label class='label label-info'>支付宝</label>"
    else 
      "<label class='label label-warning'>#{pay_channel}</label>"

    end
  end

  #记录学时的订单
  def self.should_record_hours
     [0, 2]
  end

  def self.pay_become_finish
    o = Order.all(:status =>104, :type => Order::NORMALTYPE)
    o.each do |order|
      if order.book_time + (order.quantity).hours < Time.now
        order.status = 103
        order.save
      end
    end

  end

  def product_bind_id 
    pb = ProductBinding.first(:c1_product_id => product_id) || ProductBinding.first(:c1_product_id => product_id)
    pb ? pb.id : nil
  end

  def confirm?
    confirm == 0 ? false : true
  end

  def refund_log re
    data = JSON.parse(re.to_s)
    refunds = OrderRefund.new 
    refunds.failure_code = data['failure_code']
    refunds.re_id        = data['id']
    refunds.amount       = data['amount']
    refunds.charge       = data['charge']
    refunds.respose      = data
    refunds.save
  rescue
    false
  end

  #   可否取消订单
  def can_cancel?
    status == 1 || status == 2 || status == 4
  end

  # 取消订单操作
  def cancel
    # 未付款订单
    return if status == 7
    return set_status_cancel if status == 1 || status == 2
    #cancel_book_order
  end

  # 将订单改变取消状态
  def set_status_cancel
    update(:status => STATUS_CANCEL, :cancel_at=> Time.now)
  end

  # 将订单改为退款中状态
  def set_status_refunding
    update(:status => STATUS_REFUNDING, :cancel_at=> Time.now)
  end


  # 取消练车订单
  def cancel_book_order
    # 已支付、已确定，已完成
    if Order.pay_or_done.include? status.to_i
      if set_status_cancel
        user_plan_decrease
        learn_hours_decrease 
        teacher_tech_decrease
        JPush.order_cancel id         # 推送取消订单的消息
      end
    else
      return false
    end
  end

  # 退款
  def return_money
    update(:status=>STATUS_REFUNDING)

    return if promotion_amount <= 0

    if pay_channel == 'alipay' #支付宝支付的
      content = "#{user.name.to_s}学员(手机:#{user.mobile})申请支付宝退款，金额:#{amount}"
      OptMessage.money(content)
      set_status_refunding
      return
    end

    CustomConfig.pingxx
    ch = Pingpp::Charge.retrieve(ch_id)
    reason  = "原因：用户自主取消订单 (by #{user.name})"

    re = ch.refunds.create(
        :amount => promotion_amount * 100,
        :description => reason
    )

    data = JSON.parse(re.to_s)
    OrderRefund.add(data)

    JPush.order_cancel order.id

    true
  end

end

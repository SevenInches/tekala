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


  #'未支付'=>1, '已预约'=>2, '已完成'=>3, '已确定'=>4, '退款中' => 5, '已退款' => 6, '取消'=>7
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

  has 1, :teacher_comment

    
  #推送给教练 是否接单
  # def push_to_teacher
  #   #预订的日期
  #   if status == 2 && Order::should_record_hours.include?(type)
  #     current_confirm = OrderConfirm.create(:order_id   => id,
  #                                           :user_id    => user_id, 
  #                                           :teacher_id => teacher_id, 
  #                                           :user_id    => user_id,
  #                                           :start_at   => book_time,
  #                                           :end_at     => book_time + quantity.hour,
  #                                           :status     => 0)
  #     #如果是订单教练为内部员工 测试 则不发送推送
  #     JPush::order_confirm(current_confirm.order_id) if teacher_id != 477
  #   end
  # end

  # 判断是否可退款
  def can_refund?
    ([2,3,4].include? status) && pay_at != nil
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
    when 1
      return '未支付'
    when 2
      return '已预约'
    when 3
      return '已完成'
    when 4
      return '已确定'
    when 5
      return '退款中'
    when 6
      return '已退款'
    when 7
      return '已取消'
    end
  end

  def status_word
    case self.status
    when 1
      return '待支付'
    when 2
      return '等待接单'
    when 3
      if can_comment && !user_has_comment
       return '待评价'
      else
       return '已完成'
      end
    when 4
      return '已接单'
    when 5
      return '退款中'
    when 6
      return '已退款'
    when 7
      if accept_status == 2
        return '教练繁忙'
      else
        return '已取消'
      end
    end
  end


  def created_at_format
    created_at.strftime('%Y-%m-%d %H:%M')
  end

  def pay_at_format 
   pay_at ? pay_at.strftime('%Y-%m-%d %H:%M') : ''
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


   # 添加日志
  def add_log(type, content, target=nil)
    user.add_log(type, content, target)
  end

end

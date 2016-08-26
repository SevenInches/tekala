#学车订单
class Order
  include DataMapper::Resource
  attr_accessor :no_jpush
  #before_status after save 保存之前的状态
  attr_accessor :before_status

  STATUS_CANCEL     = 6   # 已经取消
  STATUS_REFUSE     = 5   # 已拒单
  STATUS_DONE       = 4   # 已经完成
  STATUS_STUDY      = 3   # 待评价
  STATUS_RECEIVE    = 2   # 已接单
  STATUS_PAY        = 1   # 等待接单
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

  #'待接单'=>1, '已接单'=>2, '待评价'=>3, '已完成'=>4, '已拒单' => 5, '已取消' => 6
  property :status, Integer, :default => 1

  #'练车预约订单' => 1, '打包订单' => 2, '活动预付款' => 3
  property :type, Integer, :default => 1 #2 为无需记录学时

  #'C1' => 1, 'C2' => 2
  property :exam_type, Integer, :default => 1 #学车类型

  #'普通订单' => 1, '会员的订单' =>2
  property :vip, Integer, :default => 1

  #学车进度 {"科目二" => 1, "科目三" => 2}
  property :progress, Integer

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
  property :commission, Integer, :default => 0 # 代理佣金

  belongs_to :user
  belongs_to :teacher
  belongs_to :train_field
  belongs_to :product, :model => 'Product'
  belongs_to :school
  belongs_to :city

  has 1, :teacher_comment  #给教练评价

  #教练接单
  has 1, :order_confirm, :constraint => :destroy

  #推送给教练 是否接单
  def push_to_teacher
    #预订的日期
    current_confirm = OrderConfirm.create(:order_id   => id,
                                          :user_id    => user_id,
                                          :teacher_id => teacher_id,
                                          :user_id    => user_id,
                                          :start_at   => book_time,
                                          :end_at     => book_time + quantity.hour,
                                          :status     => 0)
    JGPush::order_confirm(current_confirm.order_id)
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
    return "#{year}#{month}#{day}#{hour}#{min}#{sec}#{rands}#{user_id}".to_s
  end

  def self.get_status
    return {'待接单'=>1, '已接单'=>2, '待评价'=>3, '已完成'=>4, '已拒单' => 5, '已取消' => 6}
  end

  def set_status
    case self.status
      when 1
        return '待接单'
      when 2
        return '已接单'
      when 3
        return '待评价'
      when 4
        return '已完成'
      when 5
        return '已拒单'
      when 6
        return '已取消'
    end
  end

  def status_word
    case self.status
      when 1
        return '待接单'
      when 2
        return '已接单'
      when 3
        return '待评价'
      when 4
        return '已完成'
      when 5
        return '已拒单'
      when 6
        return '已取消'
    end
  end

  def can_comment
    status == STATUS_STUDY && book_time < Time.now && teacher_comment.nil?
  end

  def user_has_comment
    teacher_comment.present?
  end

  def self.has_comment_color(status)
    case status
      when true
        return 'success'
      when false
        return 'warning'
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
    [1,2,3,4]
  end

  def self.receive_or_done
    [2,3,4]
  end

  #教练是否已经接单
  def accept_status
    return 0 if order_confirm.nil? 
    order_confirm.status 
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

  def self.pay_become_finish
    o = Order.all(:status =>STATUS_RECEIVE)
    o.each do |order|
      if order.book_time + (order.quantity).hours < Time.now
        order.status = STATUS_STUDY
        order.save
      end
    end
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

  # 取消订单操作
  def cancel
    # 未付款订单
    return if status == STATUS_REFUSE || status == STATUS_CANCEL
    return cancel_book_order if status == STATUS_PAY
  end

  # 将订单改变取消状态
  def set_status_cancel
    update(:status => STATUS_CANCEL, :cancel_at => Time.now)
  end

  # 取消练车订单
  def cancel_book_order
    # 已支付、已确定，已完成
    if Order.pay_or_done.include? status.to_i
      if set_status_cancel
        #user_plan_decrease
        #teacher_tech_decrease
        JGPush.order_cancel id         # 推送取消订单的消息
      end
    else
      false
    end
  end

   # 添加日志
  def add_log(type, content, target=nil)
    user.add_log(type, content, target)
  end

  def status_color
    case self.status
      when 1
        return 'danger'
      when 2
        return 'success'
      when 3
        return 'info'
      when 4
        return 'info'
      when 5
        return 'danger'
      when 6
        return 'warning'
      when 7
        return 'warning'
    end
  end

  # 这样写不是很好.. //2016.8.4
  def user_name(user_id)
    user_id.nil? ? "获取失败，可能这个order并未标明学员名字" : User.first(:id => user_id).name
  end

  def school_name(school_id)
    school_id.nil? ? "获取失败，可能这个order并未标明驾校名字" : School.first(:id => school_id).name
  end

  def product_name(product_id)
    product_id.nil? ? "获取失败，可能这个order并未标明产品名字" : Product.first(:id => product_id).name
  end

end

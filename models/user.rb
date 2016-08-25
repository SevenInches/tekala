# -*- encoding : utf-8 -*-
class User
  include DataMapper::Resource
  attr_accessor :password
  
  VIP    = 1
  NORMAL = 0

  validates_presence_of  :password,   :if => :password_required

  property :id, Serial
  property :id_card, String

  property :crypted_password, String, :length => 70
  property :cookie, Text, :lazy => false
  property :name, String, :default => ''
  property :nickname, String, :default => ''

  property :mobile, String, :required => true, :unique => true,  #手机号
           :messages => {
               :presence  => "手机号不能为空",
               :is_unique => "手机号已被注册"
           }

  property :city_id, Integer
  property :sex, Integer, :default => 0
  property :age, Integer
  property :avatar, String #头像

  #{"未知" => 0, "C1" => 1, "C2" => 2, "C1/C2"=>3}
  property :exam_type, Integer, :default => 1, :auto_validation => false  #报名类型

  #{"注册" => 0, "已付费" => 1, "拍照" => 2, "体检" => 3, "录指纹" => 4, "科目一" => 5, "科目二" => 6, "科目三" => 7, "考长途" => 8, "科目四" => 9, "已拿驾照" => 10, "已离开" => 11, "已入网" => 12}
  property :status_flag, Integer, :default => 0                   #学员状态

  property :motto, String                                         #宣言

  property :last_login_at, DateTime                               #最后一次登录时间
  property :device, String                                        #设备
  property :version, String                                       #版本

  property :created_at, DateTime
  property :updated_at, DateTime

  property :type, Integer, :default => 0                                         #学员类型

  property :address, String

  property :email, String                                          #电子邮件
  #用户区域

  property :latitude, String
  property :longitude, String

  property :login_count, Integer, :default => 0

  # 驾校ID
  property :school_id, Integer, :auto_validation => false

  property :teacher_id, Integer
  property :train_field_id, Integer

  property :cash_name, String                                    #付款姓名??
  property :cash_mobile, String                                  #付款手机??
  property :cash_bank_name, String                               #付款银行名称??
  property :cash_bank_card, String                               #付款银行卡号??
  property :signup_at, Date

  property :product_id, Integer, :auto_validation => false

  property :channel_id, Integer

  has n, :orders

  has 1, :signup

  has n, :user_cycle, :constraint => :destroy

  has n, :messages, :model => 'Message', :child_key => 'user_id', :constraint => :destroy

  belongs_to :school

  belongs_to :city

  belongs_to :teacher

  belongs_to :train_field

  belongs_to :channel

  # Callbacks
  before :save, :encrypt_password


  #已完成学时
  def has_hour
    return orders.all(:status => Order::pay_or_done).sum(:quantity).to_i
  end

  def avatar_thumb_url
    if avatar
      CustomConfig::QINIUURL+avatar.to_s+'?imageView2/1/w/200/h/200'
    else
      '/images/icon180.png'
    end
  end

  def city_name
    city.nil? ? '--' : city.name
  end

  def avatar_url
    if avatar
      avatar.to_s
    else
      '/images/icon180.png'
    end
  end


  def self.authenticate(id_card, password)
    user = first(:conditions => ["lower(id_card) = lower(?)", id_card]) if id_card.present?

    if user && user.has_password?(password)
      user.last_login_at = Time.now
      user.save
    end

    user && user.has_password?(password) ? user : nil
  end

  def self.authenticate_by_mobile(mobile, password)
    user = first(:conditions => ["lower(mobile) = lower(?)", mobile]) if mobile.present?
    if user && user.has_password?(password)
      user.last_login_at = Time.now
      user.save
    end
    user && user.has_password?(password) ? user : nil

  end

  def self.find_by_id(id)
    get(id) rescue nil
  end

  def has_password?(password)
    ::BCrypt::Password.new(crypted_password) == password
  end

  def date_format
    created_at.strftime('%Y-%m-%d')
  end

  def sex_format
    sex == 1 ? '男' : '女'
  end

  def password_required
    crypted_password.blank? || password.present?
  end

  def encrypt_password
    self.crypted_password  = ::BCrypt::Password.create(password) if password.present?
  end

  def self.status_flag
    {"注册" => 0, "已付费" => 1, "已入网" => 12,"拍照" => 2, "体检" => 3, "录指纹" => 4, "科目一" => 5, "科目二" => 6, "科目三" => 7, "考长途" => 8, "科目四" => 9, "已拿驾照" => 10, "已离开" => 11}
  end

  def self.city_status_flag(city)
    case city
      when '0755'
        {"注册" => 0, "已付费" => 1, "拍照" => 2, "体检" => 3, "录指纹" => 4, "科目一" => 5, "科目二" => 6, "科目三" => 7, "考长途" => 8, "科目四" => 9, "已拿驾照" => 10, "已离开" => 11}
      else
        {"注册" => 0, "已付费" => 1, "已入网" => 12,"拍照" => 2, "体检" => 3, "科目一" => 5, "科目二" => 6, "科目三" => 7, "科目四" => 9, "已拿驾照" => 10, "已离开" => 11}
    end
  end

  def status_flag_word
    case status_flag
      when 1
        "已付费"
      when 2
        "拍照"
      when 3
        "体检"
      when 4
        "录指纹"
      when 5
        "科目一"
      when 6
        "科目二"
      when 7
        "科目三"
      when 8
        "考长途"
      when 9
        "科目四"
      when 10
        "已拿驾照"
      when 11
        "已离开"
      else
        "注册"
    end
  end

  def self.status_flag_reverse(status_flag)
    status = {
        "注册" => 0,
        "已付费" => 1,
        "拍照" => 2,
        "体检" => 3,
        "录指纹" => 4,
        "科目一" => 5,
        "科目二" => 6,
        "科目三" => 7,
        "考长途" => 8,
        "科目四" => 9,
        "已拿驾照" => 10,
        "已离开" => 11
    }
    status[status_flag] if status[status_flag]
  end

  def self.exam_type
    {"C1" => 1, "C2" => 2}
  end

  def exam_type_word
    return 'C2' if exam_type == 2
    'C1'
  end

  def self.exam_type_reverse(exam_type)
    if exam_type == 'C2'
      2
    else
      1
    end
  end



  def self.work_area
    {'龙岗' => 1, '宝安' => 2, '罗湖' => 3, '福田' => 4, '南山' => 5, '盐田' => 6, '其他' => 0}
  end

  def self.live_area

    {'龙岗' => 1, '宝安' => 2, '罗湖' => 3, '福田' => 4, '南山' => 5, '盐田' => 6, '其他' => 0}

  end

  def self.wh_area

    {'武昌' => 21, '洪山' => 22, '黄陂' => 23, '东西湖' => 24, '蔡甸' => 25, '汉南' => 26, '江夏' => 27, '江岸' => 28, '江汉' => 29, '硚口' => 30, '青山' => 31, '新州' => 32, '汉阳' => 33}

  end

  def work_area_word
    case self.work_area
      when 1
        return '龙岗'
      when 2
        return '宝安'
      when 3
        return '罗湖'
      when 4
        return '福田'
      when 5
        return '南山'
      when 6
        return '盐田'
      when 7
        return '光明新区'
      when 8
        return '龙华新区'
      else
        return '其他'
    end
  end

  def live_area_word
    case self.work_area
      when 1
        return '龙岗'
      when 2
        return '宝安'
      when 3
        return '罗湖'
      when 4
        return '福田'
      when 5
        return '南山'
      when 6
        return '盐田'
      when 7
        return '光明新区'
      when 8
        return '龙华新区'
      else
        return '其他'
    end
  end

  def self.profession
    {'互联网' => 1, '金融' => 2, '公务员'=>3, '医务人员' => 4, '学生'=>5, '自由职业' => 6, '其他' => 0}
  end

  def profession_word
    case self.profession
      when 1
        return '互联网'
      when 2
        return '金融'
      when 3
        return '公务员'
      when 4
        return '医务人员'
      when 5
        return '学生'
      when 6
        return '自由职业'
      else
        return '其他'
    end

  end

  def local_word
    case self.local
      when 1
        '是'
      else
        '否'
    end

  end


  def rate
    return 5.0  if comments.size < 1
    score = 0.0
    comments.each do |comment|
      score = score + comment.rate.to_f
    end
    return (score/comments.size).to_f
    #减少一次mysql 查询
    # comments.avg(:rate).round(1)

  end

  def real_age
    if id_card.to_s.length == 18
      age = 2015 - id_card[6,4].to_i
      age > 0 ? age : 0
    else
      age = 0
    end
    age
  end

  #查询学过的用户占比
  def self.hour_user_learn_count
    num = 0
    User.all(:type => 0).each do |user|
      num+=1 if user.has_hour > 0
    end

    num

  end

  def self.vip_user_learn_count
    # User.count(:type => 1, :learn_hours.gt => 0)
    num = 0
    User.all(:type => 1).each do |user|
      num+=1 if user.has_hour > 0
    end

    num
  end

  def self.vip
    all(:type => 1)
  end

  def self.common
    all(:type => 0)
  end

  # 给用户发送短信
  def send_sms(type)
    if Padrino.env == :production
      if type == :signup
        content = "#{name}学员，恭喜您已经成功注册特快拉帐号。您的登录帐号为：#{mobile}。祝您学车愉快。"
        sms = Sms.new(:content => content, :member_mobile  => mobile)
        sms.signup
      end
    end
  end

  # 根据产品，创建报名订单
  def create_signup(product)
    return nil if product.nil?
    order = Signup.new
    order.order_no   = Order::generate_order_no_h5
    order.exam_type  = product.exam_type
    order.user_id    = self.id
    order.city_id    = product.city_id
    order.product_id = product.id
    order.amount     = product.price
    order.status     = 1
    order.school_id  = product.school_id

    order.save
    order
  end

  def invite_url
    CustomConfig::HOST+"/invite/#{invite_code}"
  end

  #是否打包教练
  def has_assign
    if self.teacher_id.nil? || self.teacher_id == 0
      return false
    else
      return true
    end
  end


  ##########
  #
  #desc 检查用户是否可以下单
  #@params
  #env:hash app版本信息等
  #teacher:object 教练
  #book_time:string 预约时间
  #
  ##########
  def can_book_order(order, book_time)
    teacher     = order.teacher
    train_field = order.train_field

    #判断教练是否存在
    return {:status => :failure, :msg => '未能找到该教练', :err_code => 1001}  if teacher.nil?
    if teacher.train_fields.first(:id => train_field.id).nil?
      return {:status => :failure, :msg => '该教练已不在该训练场', :err_code => 1002}
    end
    #/*预订的日期
    book_time_first = (book_time.to_time).strftime('%Y-%m-%d %k:00')
    book_time_second = (book_time.to_time + 1.hours).strftime('%Y-%m-%d %k:00') if order.quantity == 2

    tmp1 = []
    Order.all(:teacher_id => teacher.id, :status => Order::pay_or_done, :book_time => ((Date.today+1)..(Date.today+8.day))).each do |order|
      tmp1 << order.book_time.strftime('%Y-%m-%d %k:00')
      tmp1 << (order.book_time+1.hour).strftime('%Y-%m-%d %k:00') if order.quantity == 2
    end
    # 预订的日期 */


    #limit
    #/*如果该时段被预约 返回failure
    return {:status => :failure, :msg => '第一个时段已被预约'} if tmp1.include?(book_time_first)
    return {:status => :failure, :msg => '第二个时段已被预约'} if tmp1.include?(book_time_second)
    #如果该时段被预约 返回failure */

    return {:status => :success}
  end

  # 用户添加日志
  def add_log(type, content, target=nil)
    Log.add(self, school_id, type, content, target)
  end

end

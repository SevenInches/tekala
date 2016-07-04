# -*- encoding : utf-8 -*-
class User
  include DataMapper::Resource
  attr_accessor :beta
  attr_accessor :rank, :password, :login_action, :section, :wechat_avatar, :wechat_unionid, :group_name #内测第几批学员
  attr_accessor :before_product_id
  VIP    = 1
  NORMAL = 0
  # property <name>, <type>
  validates_presence_of  :password,   :if => :password_required

  property :id, Serial
  property :id_card, String, :default => ''

  property :crypted_password, String, :length => 70
  property :cookie, Text, :lazy => false
  property :name, String, :default => ''

  property :mobile, String, :required => true, :unique => true,
           :messages => {
               :presence  => "手机号不能为空",
               :is_unique => "手机号已被注册"
           }

  property :city_id, Integer
  property :started_at, DateTime
  property :sex, Integer, :default => 0
  property :age, Integer
  property :avatar, String
  property :score, Integer, :default => 0
  property :lavel, Integer, :default => 0
  property :birthday, Date, :default => ''

  property :daily_limit, Integer, :default => 2
  #"C1" => 1, "C2" => 2
  property :exam_type, Integer, :default => 1 #报名类型

  #{"注册" => 0, "已付费" => 1, "拍照" => 2, "体检" => 3, "录指纹" => 4, "科目一" => 5, "科目二" => 6, "科目三" => 7, "考长途" => 8, "科目四" => 9, "已拿驾照" => 10, "已离开" => 11, "已入网" => 12}
  property :status_flag, Integer, :default => 0

  # property :last_login, DateTime
  property :last_login_at, DateTime
  property :device, String
  property :version, String

  property :timeline, Text, :lazy => false

  property :motto, String, :default => ''

  property :created_at, DateTime
  property :updated_at, DateTime
  # {:普通班 => 0, :包过班 => 1} 订单交付类型 2015-07-20 mok
  property :type, Integer, :default => 0

  property :address, String

  property :email, String
  #用户区域

  #   {:龙岗 => 1, :宝安 => 2, :罗湖 => 3, :福田 => 4, :南山 => 5, :盐田 => 6, :武昌 => 21, :洪山 => 22, :黄陂 => 23, :东西湖 => 24, :蔡甸 => 25, :汉南 => 26, :江夏 => 27, :江岸 => 28, :江汉 => 29, :硚口 => 30, :青山 => 31, :新州 => 32, :汉阳 => 33, :其他 => 0} mok 2015-08-07
  property :work_area, Integer, :default => 0
  property :live_area, Integer, :default => 0
  property :local,     Integer, :default => 0

  # {:其他 => 0, :互联网 => 1, :金融 => 2, '公务员'=>3, '医务人员' => 4, '学生'=>5, '自由职业'=>6}
  property :profession, Integer, :default => 0

  property :live_card, Integer

  # mok 经纬度 2015-09-07
  property :latitude, String
  property :longitude, String

  #mok 统计学习时长 2015-09-29
  property :learn_hours, Integer, :default => 0
  property :pay_type_id, Integer

  # 是否已寄用户协议，1已寄出，0未寄出
  property :send_agreement, Integer, :default => 0

  #微信open_id
  property :open_id, String

  property :nickname, String, :default => ''

  property :referer, String

  #用户车管所预约数据
  property :photo_receipt, String
  property :book_account, String
  property :book_password, String
  property :id_card_address, String
  property :fee_receipt, String

  #邀请码
  property :invite_code, String
  property :from_code, String

  property :product_id, Integer, :default => 11

  property :school_id, Integer, :default => 0
  #用户意见，用于售前跟进
  # 0 = 待跟进
  # 1 = 强烈意向
  # 2 = 有意向
  # 3 = 只是想了解
  # 4 = 不感兴趣

  property :purpose, Integer, :default => 0

  #登陆次数
  property :login_count, Integer, :default => 0

  property :teacher_id, Integer
  property :train_field_id, Integer

  property :cash_name, String
  property :cash_mobile, String
  property :cash_bank_name, String
  property :cash_bank_card, String
  property :signup_at, Date

  has n, :orders

  #进度记录
  has n, :user_schedule, :model => 'UserSchedule', :child_key =>'user_id' , :constraint => :destroy

  has n, :comments, :model => 'UserComment', :child_key =>'user_id' , :constraint => :destroy
  #提现记录
  has n, :cash_logs, :model => 'UserWithdrawsCash', :child_key =>'user_id' , :constraint => :destroy
  #优惠券
  has n, :user_coupons

  has 1, :promotion_user, :constraint => :destroy

  #用户指导
  has 1, :user_guide, :constraint => :destroy

  #用户跟进
  has n, :user_growns, :constraint => :destroy

  has n, :user_cycle, :constraint => :destroy

  #教练接单
  has n, :order_confirms, :model => 'OrderConfirm', :child_key => 'user_id', :constraint => :destroy

  # 萌币记录
  has n, :user_score_logs, :model => 'UserScoreLog', :child_key => 'user_id', :constraint => :destroy

  has n, :messages, :model => 'Message', :child_key => 'user_id', :constraint => :destroy
  has n, :user_change_logs, :model => 'UserChange', :child_key => 'user_id', :constraint => :destroy
  # 学员钱包
  has 1, :user_wallet, :constraint => :destroy

  has 1, :user_plan, :constraint => :destroy

  has 1, :signup, :constraint => :destroy

  has 1, :recommend, :constraint => :destroy

  belongs_to :pay_type, :model => 'PayType'

  belongs_to :product, :model => 'Product'
  belongs_to :teacher, :model => 'Teacher'
  belongs_to :train_field, :model => 'TrainField'

  belongs_to :school, :model => 'School'

  belongs_to :city,  :model => 'City'

  # Callbacks
  before :save, :encrypt_password

  after :save do
    if wechat_avatar
      promotion = PromotionUser.first_or_create(:user_id => id)
      promotion.wechat_avatar  = wechat_avatar  if wechat_avatar
      promotion.wechat_unionid = wechat_unionid if wechat_unionid
      promotion_channel = PromotionChannel.first(:from => wechat_unionid)
      if promotion_channel
        promotion.event_key  = promotion_channel.event_key
      end
      promotion.save
    end

    if self.before_product_id != product_id
      plan = UserPlan.first_or_create(:user_id => id)
      plan.exam_two_standard   = product ? product.exam_two_standard : 15
      plan.exam_three_standard = product ? product.exam_three_standard : 8
      plan.save
    end

    #保存邀请码
    if self.invite_code.nil?
      self.invite_code = (5000 + id).to_s(16)
      self.save
    end

  end
  after :create, :create_promotion

  def create_promotion
    #创建学车计划
    plan = UserPlan.first_or_create(:user_id => id)

    plan.exam_two_standard   = 0
    plan.exam_three_standard = 0

    plan.exam_two_standard     = product.exam_two_standard if product
    plan.exam_three_standard   = product.exam_three_standard if product
    plan.save

    promotion = PromotionUser.new
    promotion.user_id        = id
    promotion.rank           = rank if rank
    promotion.phase          = section        if section
    promotion.wechat_avatar  = wechat_avatar  if wechat_avatar
    promotion.wechat_unionid = wechat_unionid if wechat_unionid
  end



  #发邮件给用户 params emails[array] template[string] sub[hash]填充参数
  def send_email(emails, template)

    vars = JSON.dump({"to" => emails , "sub" => {} })
    response = RestClient.post "http://sendcloud.sohu.com/webapi/mail.send_template.json",
                               :api_user => "mmxueche_service" , # 使用api_user和api_key进行验证
                               :api_key => "ZfJF6wvqa3zKkfgN",
                               :from => "service@yommxc.com", # 发信人，用正确邮件地址替代
                               :fromname => "萌萌学车",
                               :substitution_vars => vars,
                               :template_invoke_name => template,
                               :subject => "萌萌学车介绍及报考攻略",
                               :resp_email_id => 'true'
    return response
  end

  def product_name
    product ? product.name : 'Error未指定产品'
  end

  #已完成学时
  def has_hour
    return orders.all(:status => Order::pay_or_done, :type => Order::should_record_hours).sum(:quantity).to_i
  end


  def avatar_thumb_url
    if avatar
      CustomConfig::QINIUURL+avatar.to_s+'?imageView2/1/w/200/h/200'
    else
      if promotion_user && promotion_user.wechat_avatar.present?
        promotion_user.wechat_avatar
      else
        CustomConfig::HOST + '/images/icon180.png'
      end
    end
  end

  def city_name
    city.nil? ? '--' : city.name
  end

  def avatar_url
    if avatar
      CustomConfig::QINIUURL+avatar.to_s
    else
      if promotion_user && promotion_user.wechat_avatar.present?
        promotion_user.wechat_avatar
      else
        CustomConfig::HOST + '/images/icon180.png'
      end
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
    current_user = User.get id
    self.before_product_id = current_user ? current_user.product_id : nil
    self.exam_type = 1 if self.exam_type.nil?
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

  def self.exam_type
    {"C1" => 1, "C2" => 2}
  end

  def exam_type_word
    return 'C2' if exam_type == 2
    'C1'
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

  def vip?
    type == 1
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
        content = "#{name}学员，恭喜您已经成功注册萌萌学车帐号。您的登录帐号为：#{mobile}。在使用萌萌学车服务过程中，有任何问题欢迎通过微信公众号或者电话4008-456-866进行咨询。祝您学车愉快。"
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

  # 获得推荐人名字
  def referer_name
    return '' if referer.to_s == ''
    target = User.first(:mobile=>referer.to_s)
    return target.nil? ? '' : target.name
  end


  def invite_url
    CustomConfig::HOST+"/invite/#{invite_code}"
  end

  def self.city
    return {'深圳' => '0755', '武汉' => '027', '重庆' => '023'}
  end

  def self.purpose
    return {'待跟进' => 0, '强烈意向' => 1, '有意向' => 2, '只是想了解' => 3, '不感兴趣' => 4}
  end

  def purpose_name
    case self.purpose
      when 0
        return '待跟进'
      when 1
        return '强烈意向'
      when 2
        return '有意向'
      when 3
        return '只是想了解'
      when 4
        return '不感兴趣'
    end
  end

  def purpose_color
    case self.purpose
      when 0
        return 'default'
      when 1
        return 'success'
      when 2
        return 'info'
      when 3
        return 'warning'
      when 4
        return 'default'
    end
  end


  def check_first_tweet
    tweet = Tweet.first(:user_id => id)
    if tweet.nil?
      words = ['#萌萌学车#我来到萌萌学车了，拿到驾照来一场说走就走的旅行吧~',
               '#萌萌学车#一起围观萌萌吧，钱就该花在刀刃上，学车最便、最省、最优质！',
               '#萌萌学车#学车我话事，教练、场地任我选~',
               '#萌萌学车#驾照都没有，活该你单身！技多不压身，桃花朵朵开~',
               '#萌萌学车#即将开启我愉快的学车之旅…']
      pic   = ['tweet/signup02', 'tweet/signup03', 'tweet/signup04', 'tweet/signup05', 'tweet/signup01']

      num = rand(4)
      tweet = Tweet.new
      tweet.user_id = id
      tweet.content = words[num]
      TweetPhoto.create(:tweet_id => tweet.id, :user_id => id, :url => pic[num]) if tweet.save

    end
  end
  #是否打包教练
  def has_assign
    if self.teacher_id.nil? || self.teacher_id == 0
      return false
    else
      return true
    end
  end

  def wuhan?
    city == '027'
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
  def can_book_order(env, order, book_time)
    #/*如果用户是在科目一则不能下单
    teacher     = order.teacher
    train_field = order.train_field

    if status_flag <= 5 && type == User::VIP
      return {:status   => :failure,
              :msg      => '需通过科目一考试后才可进行预约练车。如已通过科目一考试，请联系小萌更新学习进度哦~',
              :err_code => 2001 }
    end
    #如果用户是在考科目一则不能下单*/

    #limit
    #/*学时限制
    if status_flag < 7
      if user_plan.exam_two + order.quantity > user_plan.exam_two_standard
        return {:status => :failure,
                :msg    => '您当前科目的预约学时已达到小萌建议的学习时长，还没学会？请让小萌了解您的学车进度，提出申请后再进行预约哦。',
                :code   => 2002 }
      end
    else
      if user_plan.exam_three + order.quantity > user_plan.exam_three_standard
        return {:status => :failure,
                :msg    => '您当前科目的预约学时已达到小萌建议的学习时长，还没学会？请让小萌了解您的学车进度，提出申请后再进行预约吧。',
                :code   => 9003 }

      end
    end
    #学时限制 */

    #判断教练是否存在
    return {:status => :failure, :msg => '未能找到该教练', :err_code => 1001}  if teacher.nil?
    if teacher.train_fields.first(:id => train_field.id).nil?
      return {:status => :failure, :msg => '该教练已不在该训练场', :err_code => 1002}
    end
    #/*预订的日期
    book_time_first = (book_time.to_time).strftime('%Y-%m-%d %k:00')
    book_time_second = (book_time.to_time + 1.hours).strftime('%Y-%m-%d %k:00') if order.quantity == 2

    tmp = []
    Order.all(:teacher_id => teacher.id, :status => Order::pay_or_done, :book_time => ((Date.today+1)..(Date.today+8.day))).each do |order|
      tmp << order.book_time.strftime('%Y-%m-%d %k:00')
      tmp << (order.book_time+1.hour).strftime('%Y-%m-%d %k:00') if order.quantity == 2
    end
    # 预订的日期 */

    #/* 不能预约当天时间
    if book_time.to_date <= Date.today
      return {:status => :failure, :msg => '不能预约当天/之前时间练车'}
    end
    # 不能预约当天时间*/

    #/*如果现在时间是18点 则不允许预约隔天的
    if Time.now.strftime('%H').to_i > 17 &&  book_time.to_time <= (Date.today + 2.days).to_time
      return {:status => :failure, :msg => '18点后不能预约第二天练车'}
    end
    #如果现在时间是18点 则不允许预约隔天的*/

    #limit
    #/*如果该时段被预约 返回failure
    return {:status => :failure, :msg => '第一个时段已被预约'} if tmp.include?(book_time_first)
    return {:status => :failure, :msg => '第二个时段已被预约'} if tmp.include?(book_time_second)
    #如果该时段被预约 返回failure */
    #limit

    # /*限制用户一天只能约N个小时
    tmp = []
    Order.all(:user_id => id, :status => Order::pay_or_done, :book_time => ((book_time_first.to_date)..(book_time_first.to_date+1.day))).each do |order|
      tmp << order.book_time.strftime('%Y-%m-%d %k:00')
      tmp << (order.book_time+1.hour).strftime('%Y-%m-%d %k:00') if order.quantity == 2
    end

    days_count   = tmp.map{|val| val[0..9] }.count(book_time_first[0..9])
    days_current = days_count
    days_count  += order.quantity #今天学时
    return {:status => :failure, :msg => "您当天已学 #{days_current} 个学时，为保证教学质量，防止疲劳学习，建议一天最多学习 #{daily_limit} 小时哦！"} if days_count > daily_limit
    # 限制用户一天只能约4个小时 */
    return {:status => :success}
  end

end

class Teacher
  include DataMapper::Resource

  attr_accessor :password, :teaching_age, :driving_age, :qiniu_avatar
  
  C1 = [1,3]
  C2 = [2,3]
  C2ADD = 20
  # property <name>, <type>
  property :id, Serial
  property :crypted_password, String, :length => 70

  property :name, String, :required => true,
           :messages => {:presence => '请填写姓名'}
  property :age, Integer
  property :sex, Integer, :default => 1#性别 1男 0女
  property :id_card, String
  property :bank_card, String, :default => ''

  property :hometown, String
  property :avatar, String, :auto_validation => false
  property :bank_card_photo, String, :auto_validation => false
  
  # 结算类型，默认是按天结算，合作久的教练改为按周结算
  property :pay_type, String, :default => 'day'

  #银行卡支行名称
  property :bank_name, String, :default => ''

  #银行卡持卡人姓名
  property :bank_account_name, String, :default => ''

  #'未知'=>1, 'C1'=>2, 'C2'=>3, 'C1/C2'=>4 #mok 2015-07-24
  property :exam_type, Integer, :default => 2 #教练教学的车型
  # '科目二/科目三 => 1', '科目二 => 2'，'科目三 => 3'
  property :tech_type, Integer, :default => 1 #教练教学的类型

  property :mobile, String, :unique => true, :required => true,
           :messages => {:is_unique => "手机号已经存在",
                          :presence => '请填写联系电话'}

  property :wechart, String, :default => ''
  property :email,  String, :default => ''
  property :address, String, :default => ''

  property :price, Integer, :default => 119, :min => 0
  property :promo_price, Integer, :default => 119, :min => 0
  property :created_at, DateTime
  property :qq, String, :default => ''

  #教练排名
  property :sort, Integer,:default => 0

  #教练状态 0休假 1正常使用
  property :status_flag , Integer, :default => 1
  
  #'待审核'=>1, '审核通过'=>2, '审核不通过'=>3, '报名' => 4
  property :status, Integer, :default => 1
  
  #用户区域
  property :area, Integer, :default => 0

  property :map, String, :auto_validation => false

  property :date_setting, String, :default => ''

  property :city_id, Integer

  #教练权重
  property :weight, Integer, :default => 0
  
  property :open, Integer, :default => 1

  property :login_count, Integer, :default => 0

  property :school_id, Integer, :default => 0

  has n, :comments, :model => 'TeacherComment', :child_key =>'teacher_id' , :constraint => :destroy

  has n, :orders

  has n, :train_fields, 'TrainField', :through => :teacher_field, :via => :train_field


  # 教练钱包
  belongs_to :school

  mount_uploader :avatar, TeacherAvatar

  before :save, :encrypt_password

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



  def avatar_thumb_url
     avatar.thumb && avatar.thumb.url ? CustomConfig::HOST + avatar.thumb.url : CustomConfig::HOST + '/m/images/default_teacher_avatar.png' 

  end 

  def avatar_url
     avatar && avatar.url ? CustomConfig::HOST + avatar.url : '/images/teacher_default_photo.png'
  end

  

  def driving_age 
    5
  end

  def teaching_age 
    5
  end

  def has_hour
    hour = orders.all(:status => Order::pay_or_done, :type => Order::PAYTOTEACHER).sum(:quantity).to_i
    return hour-50 if id == 170
    return hour-30 if id == 278
    return hour
  end

  def self.get_flag
    {'正常使用' => 1, '休假' => 0}
  end

  def self.get_vip
    {'VIP' => 1, '普通' => 0}
  end

  def self.status_flag 
    {"休假" =>0 , "正常使用" =>1}
  end

  def self.pay_type 
    {"周结算" =>'week' , "天结算" =>'day', '科目二' => 'exam_two', '科目三' => 'exam_three'}
  end

  def self.city_pay_type(city) 
    case city
    when '0755'
      {"周结算" =>'week' , "天结算" =>'day'}
    when '027'   
      {'科目二' => 'exam_two', '科目三' => 'exam_three'}
    when '023'   
      {'科目二' => 'exam_two', '科目三' => 'exam_three'}
    end
  end

  def format_created
    created_at.strftime('%Y-%m-%d')
  end

  def comment_size
    comments.size
  end

  def created_at_format 
    created_at.strftime('%m月%d日 %H:%m')
  end

  def status_color 
    case self.status
    when 0
      return 'danger'
    when 201
      return 'success'
    when 200
      return 'info'
    when 100
      return 'warning'
    end

  end


  def status_flag_color 
    case self.status_flag
    when 0
      return 'danger'
    when 1
      return 'success'
    end
  end

  def self.exam_type
    {"未知" => 1, "C1" => 2, "C2" => 3, "C1/C2" => 4}
  end

  def exam_type_word 
    case exam_type
    when 2
      return 'C1'
    when 3
      return 'C2'
    when 4
      return 'C1/C2'
    end
  end

  def self.status
    {'待审核'=>1, '审核通过'=>2, '审核不通过'=>3, '报名' => 4}
  end

  def status_word
    case status
      when 1 then '待审核'
      when 2 then '审核通过'
      when 3 then '审核不通过'
      when 4 then '报名'
    end
  end

  def self.authenticate(mobile, password)
    teacher = first(:conditions => ["lower(mobile) = lower(?)", mobile]) if mobile.present?

    teacher && teacher.has_password?(password) ? teacher : nil

  end

  def has_password?(password)
    ::BCrypt::Password.new(crypted_password) == password
  end

  def password_required
    crypted_password.blank? || password.present?
  end

  def encrypt_password
    self.crypted_password = ::BCrypt::Password.create(password) if password.present?
  end

  #教练空闲时刻表
  def date_setting_filter
      JSON.parse(date_setting)
    rescue => err 
      return JSON.parse('{"week":[0,1,2,3,4,5,6],"time":[7,20]}')
  end

  def self.open
    return {'开' => 1, '关' => 0}
  end

  def self.tech_type
    return {'科目二/科目三' => 0, '科目二' => 1, '科目三' => 2}
  end


  def tech_type_word
    case self.tech_type
    when 0
      return '科目二/科目三'
    when 1
      return '科目二' 
    when 2
      return '科目三' 
    end
  end

  #更新旧数据
  def refresh_tech_hours
    if self.tech_hours != self.has_hour
      self.tech_hours = self.has_hour
    end
    self.save
  end

  def train_field_str
    train_fields.map(&:name).join(',')
  end
  # 是否VIP教练
  def vip?
    vip == 1
  end


  #学员可预约时间
  def time_can_book 
    #/*获取教练自定义接单时间
    setting_time = date_setting_filter["time"].map{ |data| data.to_i }
    teacher_setting_time = []
    setting_time[0].upto(setting_time[1]).each do |i|
      teacher_setting_time << i
    end
    teacher_setting_week = date_setting_filter["week"].map{ |data| data.to_i }
    #获取教练自定义接单时间*/

    tmp          = []
    time_between = (Date.today+1)..(Date.today+8.day)
    orders(:status => Order::pay_or_done, :book_time => time_between ).each do |order|
      tmp << order.book_time.strftime('%Y-%m-%d %k:00')
      tmp << (order.book_time+1.hour).strftime('%Y-%m-%d %k:00') if order.quantity == 2
    end
    #生成近7天的预订情况
    array = []
    (1..7).each do |i|
       current_date = (Date.today+i).strftime('%Y-%m-%d')
       week = (Date.today+i).strftime('%w') 
       date_time=[]
       time_array = []
       (0..23).each do |time|
          temp_time = time
          time = " #{time}" if time < 10
          #如果该时间已经被预订，则显示不可约 0
          if tmp.include?(current_date+" #{time}:00") || (Time.now.strftime('%H').to_i > 17 && i == 1 ) || !teacher_setting_time.include?(temp_time) || !teacher_setting_week.include?((Date.today+i.days).wday)
            time_array << 0
          else
            time_array << 1
          end
       end
       array << time_array
    end
    result = {}
    result.store('data', array)
    result.store('status', 'success')
    result.to_json
  end


  # 用户添加日志
  def add_log(type, content, target=nil)
    Log.add(self, school_id, type, content, target)
  end

  def self.status_reverse(status)
    statuses = {'待审核'=>1, '审核通过'=>2, '审核不通过'=>3, '报名' => 4}
    statuses[status] if statuses[status]
  end

  def self.tech_type_reverse(tech_type)
    types = {'科目二/科目三' => 0, '科目二' => 1, '科目三' => 2}
    types[tech_type] if types[tech_type]
  end

  def self.exam_type_reverse(exam_type)
    if exam_type == 'C2'
      2
    else
      1
    end
  end
end

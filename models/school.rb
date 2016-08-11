class School
  include DataMapper::Resource
  require 'chinese_name'

  attr_accessor :password

  # property <name>, <type>
  property :id, Serial
  property :city_id, Integer
  property :name, String
  property :address, String
  property :contact_phone, String
  property :profile, Text   #简介
  property :is_vip, Boolean #vip
  property :is_open, Boolean, :default => 1 #是否开放
  property :weight, Integer  #权重
  property :master, String   #校长
  property :logo, String     #logo
  property :found_at, Date
  property :latitude, String
  property :longitude, String
  property :config, Text     #配置
  property :note, String
  property :created_at, DateTime
  property :updated_at, DateTime

  #新增字段
  #property :contact_user, String
  #property :teacher_count, Integer
  #property :car_count, Integer
  #property :area_count, Integer
  #property :shop_count, Integer
  #1-10，五星好评，9代表4.5星
  #property :rank, Integer

  belongs_to :city

  has n, :maps  # 训练场数字地图
  
  has n, :shops # 门店
  has n, :finances          # 财务记录
  has n, :finance_reports   # 财务报告
  has n, :logs  # 操作日志
  has n, :products #产品
  has n, :users
  has n, :teachers

  before :save, :encrypt_password

  after :create do |school|
    tid = school.demo_teacher
    fid = school.demo_field
    school.demo_product
    if tid.present?
      tid.each do |teacher|
        TeacherTrainField.new(:teacher_id=>teacher, :train_field_id=>fid).save
      end
    end
  end

  def city_name
    city.nil? ? '--' : city.name
  end

  def add_product(name, price)
    Product.create(:school_id => id, :name=>name, :price=>price).save
  end

  def demo_teacher
    names = ChineseName.generate(num = 3)
    teacher_array = []
    names.each do |name|
      new_teacher = Teacher.new(:password=>'123456', :open=>1, :status_flag=>1, :exam_type=>4)
      new_teacher.name = name[0]
      new_teacher.sex = (name[1]=='女')? 0 : 1
      new_teacher.age = Date.today.year - name[2].to_i
      new_teacher.school_id = id
      new_teacher.mobile = '138'+rand.to_s[2..9]
      if new_teacher.save
        teacher_array.push(new_teacher.id)
      end
    end
    teacher_array
  end

  def demo_field
    field = TrainField.new(:display=>1,:open=>1)
    field.name = self.generate_field
    field.city_id = city_id
    field.school_id = id
    field.save
    field.id
  end

  def demo_product
    products = [{:name => '普通班', :price => 5999}, {:name => 'VIP班', :price => 6999}]
    products.each do |product|
      new_product      = Product.new(:show => 1)
      new_product.name      = product[:name]
      new_product.price     = product[:price]
      new_product.school_id = id
      new_product.city_id   = city_id
      new_product.deadline = '2016-10-31'
      new_product.save
    end
  end

  def generate_field
    first_names = %w(春 夏 秋 东 梅 兰 竹 菊 东 南 西 北 人民 解放 民主 团结 中山 少年 北京 上海 天津 南京 凤凰)
    first = first_names.sample
    last_names = %w(路 村 湖 山 庙 公园 体育馆 门 宫 庄 里 桥 科技园 大街)
    last = last_names.sample
    first+last+'训练场'
  end

  def open_word
    is_open ? '开放' : '关闭'
  end

  def encrypt_password
    self.crypted_password = ::BCrypt::Password.create(password) if password.present?
  end

  def self.schools
    self.all.collect { |sch| [sch.name, sch.id] }
  end

  def self.first_school_id(school)
    current = self.first(:name.like => "%#{school}%")
    current.id if current.present?
  end

  def consult_count
    0
  end

  def student_count
    users.count
  end

  def teacher_count
    teachers.count
  end

  def car_count
    0
  end

  def shop_count
    shops.count
  end

  def last_7days_signup_count
    start_date  = Date.today - 6.days
    end_date    = Date.today
    users.all(:created_at =>(start_date..end_date)).count
  end

end

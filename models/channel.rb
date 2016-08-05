class Channel
  include DataMapper::Resource
  attr_accessor :password

  # property <name>, <type>
  property :id, Serial
  property :school_id, Integer
  property :gen_key, String
  property :name, String
  property :type, Integer
  property :scan_count, Integer
  property :refund_count, Integer
  property :fee, Integer
  property :created_at, DateTime
  property :updated_at, DateTime
  property :contact_phone, String, :required => true, :unique => true, :messages => {
    :presence  => "手机号不能为空",
    :is_unique => "手机号已被注册"
    }
  property :logo, String
  property :config, Text
  property :crypted_password, String, :length => 70
  property :total_earn, Integer, :default => 0
  property :signup_count, Integer, :default => 0
  property :pay_count, Integer, :default => 0

  has n, :orders

  before :save, :encrypt_password

  def self.channels
    self.all.collect { |cha| [cha.name, cha.id] }
  end

  def self.authenticate(phone, password)
    school = first(:conditions => ["lower(contact_phone) = lower(?)", phone]) if phone.present?
    school && school.has_password?(password) ? school : nil
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

  def conversion_rate
    signup_count == 0 ? 0 : pay_count.to_f / signup_count
  end

  def sales_this_month(channel_id)
    pay_status = [2, 3, 4]
    month_beginning = Date.strptime(Time.now.beginning_of_month.to_s, '%Y-%m-%d')
    this_month = month_beginning .. Date.tomorrow
    return Order.all(:created_at => this_month, :status => pay_status, :channel_id => channel_id).blank? ? 0 : Order.all(:created_at => this_month, :status => pay_status, :channel_id => channel_id).sum(:commission)
  end

end
# -*- encoding : utf-8 -*-
class Account
  include DataMapper::Resource
  include DataMapper::Validate
  attr_accessor :password, :password_confirmation

  property :id,               Serial
  property :name,             String
  property :surname,          String
  property :email,            String
  property :crypted_password, String, :length => 70
  property :role,             String
  property :city,             String

  validates_presence_of      :email, :role
  validates_presence_of      :password,                          :if => :password_required
  validates_presence_of      :password_confirmation,             :if => :password_required
  validates_length_of        :password, :min => 4, :max => 40,   :if => :password_required
  validates_confirmation_of  :password,                          :if => :password_required
  validates_length_of        :email,    :min => 3, :max => 100
  validates_uniqueness_of    :email,    :case_sensitive => false
  validates_format_of        :email,    :with => :email_address
  validates_format_of        :role,     :with => /[A-Za-z]/

  before :save, :encrypt_password

  def self.get_role
    {"超级管理员" => 'admin', "运营" => "operation", "商务" => "business", "城市经理" => "city_manager", '财务' => 'finance' }
  end

  def role_word
    case self.role
    when "admin"
      return '超级管理员'
    when 'operation'
      return '运营'
    when "business"
      return '商务'
    when "finance"
      return '财务'
    when 'city_manager'
      return '城市经理'
    end

  end
  def self.city
    return {'深圳' => '0755', '武汉' => '027', '重庆' => '023'}
  end
  def city_word
    case self.city
    when '0755'
      return '深圳'
    when '027'
      return '武汉'
    when '023'
      return '重庆'
    end
  end
 
  def self.authenticate(email, password)
    account = first(:conditions => ["lower(email) = lower(?)", email]) if email.present?
    account && account.has_password?(password) ? account : nil
  end


  def self.find_by_id(id)
    get(id) rescue nil
  end

  def has_password?(password)
    ::BCrypt::Password.new(crypted_password) == password
  end

  private

  def password_required
    crypted_password.blank? || password.present?
  end

  def encrypt_password
    self.crypted_password = ::BCrypt::Password.create(password) if password.present?
  end
end

class Seller
  include DataMapper::Resource
  attr_accessor :password, :password_confirmation
  # property <name>, <type>
  property :id, Serial
  property :name, String
  property :crypted_password, String
  property :mobile, String
  property :wechat, String
  
  #validate
  validates_presence_of      :name, :mobile
  validates_presence_of      :password,  :if => :password_required
  validates_length_of        :password, :min => 4, :max => 40,   :if => :password_required
  validates_uniqueness_of    :mobile, :case_sensitive => false

  #Callback
  before :save, :encrypt_password

  ##
  # This method is for authentication purpose.
  #

  def self.authenticate_by_mobile(mobile, password)
    seller = first(:conditions => ["lower(mobile) = lower(?)", mobile]) if mobile.present?
    seller && seller.has_password?(password) ? seller : nil
  end

  ##
  # This method is used by AuthenticationHelper
  #
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

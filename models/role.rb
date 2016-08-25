#驾校人员管理
class Role
  include DataMapper::Resource

  attr_accessor :password

  # property <name>, <type>
  property :id, Serial
  property :name, String
  property :school_id, Integer
  property :mobile, String
  property :crypted_password, String
  property :last_login_at, DateTime
  property :created_at, DateTime
  property :cate, Integer

  belongs_to :school

  before :save, :encrypt_password

  def self.authenticate(school_no, phone, password)
    school = School.first(:school_no => school_no)
    if school.present?
      role_ids  = school.roles.aggregate(:id)
      role_user = Role.first(:id =>role_ids, :mobile =>phone) if phone.present?
      if role_user.present? && role_user.has_password?(password)
        role_user.last_login_at = Time.now
        role_user.save
        role_user
      else
        nil
      end
    end
  end

  def change_psd(school_no, mobile,old_password, new_password , confirm_password)
    role_user = self.class.authenticate(school_no, mobile, old_password)
    if role_user && new_password == confirm_password
      role_user.password = new_password
      role_user.save
      role_user
    else
      nil
    end
  end

  def change_other_psd(id, new_password , confirm_password)
    user = Role.first(:id => id)
    if user && new_password == confirm_password
      user.password = new_password
      user.save
      user
    else
      nil
    end
  end

  def self.find_by_id(id)
    get(id) rescue nil
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

  def self.get_cate(key=nil)
    words = {
        1 => '管理员',
        2 => '校长',
        3 => '财务',
        4 => '客户主任',
        5 => '门店经理',
    }
    if key.present?
      words[key]
    else
      words
    end
  end

  def cate_word
    case cate
      when 1
        "管理员"
      when 2
        "校长"
      when 3
        "财务"
      when 4
        "客户主任"
      else
        "门店经理"
    end
  end

end

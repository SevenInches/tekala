class TeacherWalletLog
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial
  property :teacher_id, Integer
  property :teacher_wallet_id, Integer
  property :amount, Float
  property :before_pay, Float
  property :after_pay, Float
  property :type, Integer
  property :status, Integer
  property :note, String
  property :log_no, String
  property :operator, String

  property :created_at, DateTime
  
  def generate_log_no
    year    = Time.now.year
    month   = "%02d" % Time.now.month
    day     = "%02d" % Time.now.day
    hour    = "%02d" % Time.now.hour
    min     = "%02d" % Time.now.min
    sec     = "%02d" % Time.now.sec
    rands   = rand(9999)
    return "TL-#{teacher_id}-#{year}#{month}#{day}#{hour}#{min}#{sec}-#{rands}".to_s
  end

  # 1=收入, 11=奖励, 21=平台支付, 31=取现
  def type_name
    {1 => '收入', 11=>'奖励', 21=>'平台支付', 31=>'取现'}[type].to_s
  end

  def self.create_log(teacher_id, amount, note, type)
    teacher_wallet  = TeacherWallet.first_or_create(:teacher_id=>teacher_id)
    
    log = TeacherWalletLog.new
    log.teacher_id        = teacher_id
    log.teacher_wallet_id = teacher_wallet.id
    log.amount            = amount
    log.before_pay        = teacher_wallet.amount
    log.after_pay         = teacher_wallet.amount + log.amount
    log.note              = note
    log.status            = 1
    log.type              = type
    log.log_no            = log.generate_log_no
    log.save
    
    teacher_wallet.amount += log.amount
    teacher_wallet.save

    log
  end

  def self.create_income(teacher_id, amount, note)
    TeacherWalletLog.create_log(teacher_id, amount, note, 1)
  end

  def self.create_pay(teacher_id, amount, note)
    TeacherWalletLog.create_log(teacher_id, amount, note, 21)
  end

  def self.create_cash(teacher_id, amount, note)
    TeacherWalletLog.create_log(teacher_id, amount, note, 31)
  end



end

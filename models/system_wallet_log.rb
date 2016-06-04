class SystemWalletLog
  include DataMapper::Resource

  PAY     = 0
  INCOME  = 1

  property :id,         Serial
  property :amount,     Float
  property :before_pay, Float
  property :after_pay,  Float

  # 0=转出 1=转入
  property :type, Integer, :default => 0
  # 类型
  property :category, Integer, :default => 0

  property :log_no,         String
  property :note,           String
  property :pay_record_id,  Integer

  property :pay_at,         Date
  property :created_at, DateTime

  after :save, :push_message

  # 推送消息
  def push_message
    return if Padrino.env == :development
    
    # 若支出，则发送推送消息
    if pay? && amount.to_i != 0
      content = "财务|金额:#{amount.to_i}元,#{note}"
      OptMessage.money(content)

      # 若系统少于5000元，则发出警告，提示充值
      if after_pay.to_f < 5000 
        OptMessage.alert("系统余额不足5000元，请尽快充值", :money)
      end
    end
  end

  def pay?
    type == PAY
  end

  def self.total_pay_amount
    all(:type => PAY).sum(:amount).to_i
  end

  def self.generate_log_no
    year    = Time.now.year
    month   = "%02d" % Time.now.month
    day     = "%02d" % Time.now.day
    hour    = "%02d" % Time.now.hour
    min     = "%02d" % Time.now.min
    sec     = "%02d" % Time.now.sec
    rands   = rand(9999)
    return "SL-#{year}#{month}#{day}#{hour}#{min}#{sec}-#{rands}".to_s
  end
  
end

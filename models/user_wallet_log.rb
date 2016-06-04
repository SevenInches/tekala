class UserWalletLog
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial
  property :user_id, Integer
  property :user_wallet_id, Integer
  property :amount, Float
  property :before_pay, Float
  property :after_pay, Float
  property :type, Integer
  property :status, Integer
  property :note, String
  property :log_no, String
  property :operator, String
  property :created_at, DateTime
  
  belongs_to :user
  belongs_to :user_wallet
  
  def generate_log_no
    year    = Time.now.year
    month   = "%02d" % Time.now.month
    day     = "%02d" % Time.now.day
    hour    = "%02d" % Time.now.hour
    min     = "%02d" % Time.now.min
    sec     = "%02d" % Time.now.sec
    rands   = rand(9999)
    return "UL-#{user_id}-#{year}#{month}#{day}#{hour}#{min}#{sec}-#{rands}".to_s
  end

end

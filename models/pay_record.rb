class PayRecord
  include DataMapper::Resource

  property :id, Serial
  property :teacher_id, Integer
  property :hour_count, Integer
  property :amount,     Integer
  property :note,       String
  property :operator,   String

  # 0 未付款 1 已支付
  property :status,     Integer, :default => 0
  property :pay_at,     DateTime
  property :bank_id,    String
  property :bank_name,  String
  property :start_date, Date
  property :end_date,   Date

  property :created_at,     DateTime
  property :updated_at,     DateTime
  
  belongs_to :teacher

  def create_wallet_log
    wallet = SystemWallet.first
    return if wallet.nil?

    log = SystemWalletLog.first(:pay_record_id=>id)
    return if log

    log = SystemWalletLog.create(:pay_record_id=>id)
    log.log_no      = SystemWalletLog.generate_log_no
    log.amount      = amount
    log.before_pay  = wallet.amount
    log.after_pay   = wallet.amount - amount
    log.note        = "支付给#{teacher.name}教练 #{amount}元(#{bank_name} #{bank_id})"
    log.pay_at      = Date.today
    log.save

    wallet.amount -= amount
    wallet.save
  end

  def reward(per_hour, count)
    wallet = SystemWallet.first
    return if wallet.nil?

    amount = per_hour * count

    log = SystemWalletLog.create(:pay_record_id=>id)
    log.log_no      = SystemWalletLog.generate_log_no
    log.amount      = amount
    log.before_pay  = wallet.amount
    log.after_pay   = wallet.amount - amount
    log.note        = "支付给#{teacher.name}教练 自动档补贴，每小时#{per_hour}元, 共#{amount}元(#{bank_name} #{bank_id})"
    log.save

    wallet.amount -= amount
    wallet.save
  end


end

class SystemWallet
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial
  property :amount, Float

  def self.current_amount
    SystemWallet.first.amount
  end
  
    # 充值
  def self.charge(amount)
    wallet = SystemWallet.first
    return false if wallet.nil?
    log = SystemWalletLog.create(:pay_record_id=>0)
    log.log_no = SystemWalletLog.generate_log_no
    log.amount = amount
    log.before_pay = wallet.amount
    log.after_pay  = wallet.amount + amount
    
    log.pay_at = Date.today
    log.note   = "系统充值#{amount}元"
    log.type   = 1
    log.save

    wallet.amount += amount

    if wallet.save
      return true
    else
      return false
    end

  end
end

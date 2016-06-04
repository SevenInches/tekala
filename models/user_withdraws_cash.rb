class UserWithdrawsCash
  include DataMapper::Resource

  property :id, Serial
  property :user_id, Integer
  property :name, String
  property :mobile, String
  property :score, Integer
  property :bank_name, String
  property :bank_card, String
  property :device, String
  property :status, Integer, :default => 0 #[0=>'未知' 1=>'申请中' 2=>'提现处理中' 3=>'提现完成' 4=>'拒绝']
  property :created_at, DateTime
  property :updated_at, DateTime

  belongs_to :user

  def status_flag
    case self.status
    when 0
      return 'default'
    when 1
      return 'success'
    when 2
      return 'warning'
    when 3
      return 'info'
    when 4
      return 'danger'
    end
  end

  def status_word
    case self.status
    when 0
      return '未知'
    when 1
      return '申请中'
    when 2
      return '提现处理中'
    when 3
      return '提现完成'
    when 4
      return '拒绝'
    end
  end
end

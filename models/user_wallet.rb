class UserWallet
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial
  property :user_id, Integer
  property :amount, Float, :default=>0.0
  
  property :created_at, DateTime
  property :updated_at, DateTime

  belongs_to :user
  
  has n, :user_wallet_logs

end

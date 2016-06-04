class TeacherWallet
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial
  property :teacher_id, Integer
  property :amount, Float, :default=>0.0

  property :created_at, DateTime
  property :updated_at, DateTime
  
  belongs_to :teacher

  has n, :teacher_wallet_logs
  
end

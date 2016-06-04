class UserGuide
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial
  property :guide, Boolean, :default => false
  property :take_photo, Boolean, :default => false
  property :examination, Boolean, :default => false
  property :signup_account, Boolean, :default => false
  property :fingerprint, Boolean, :default => false
  property :receipt, Boolean, :default => false
  property :first_exam, Boolean, :default => false
  property :user_id, Integer
  property :created_at, DateTime

  belongs_to :user, :model => 'User', :child_key => 'user_id'

end

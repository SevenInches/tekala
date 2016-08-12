class UserPlan
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial
  property :user_id, Integer
  property :exam_two, Integer, :default => 0
  property :exam_two_standard, Integer, :default => 0
  property :exam_three, Integer, :default => 0
  property :exam_three_standard, Integer, :default => 0
  property :created_at, DateTime

  belongs_to :user

end

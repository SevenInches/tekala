#学员投诉
class Complain
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial
  property :content, String
  property :user_id, Integer
  property :created_at, DateTime
  property :school_id, Integer

  belongs_to :user
  belongs_to :school

end

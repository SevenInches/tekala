class UserExam
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial
  property :exam_one, Integer
  property :exam_four, Integer

  belongs_to :user
end

class TeacherRank
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial
  property :teacher_id, Integer
  property :month, String
  property :type, String
  property :val, Float
  property :total_score, Float
  property :created_at, DateTime

  belongs_to :teacher
  
end

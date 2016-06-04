class TeacherNotice
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial
  property :teacher_id, Integer
  property :type, String
  property :note, String
  property :value, Integer
  property :created_at, DateTime
end

class TeacherTrainField
  
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial
  property :teacher_id, Integer
  property :train_field_id, Integer
  property :sort, Integer

  belongs_to :teacher, "Teacher", :parent_key => :id, :child_key => :teacher_id
  belongs_to :train_field, "TrainField", :parent_key => :id, :child_key => :train_field_id
end

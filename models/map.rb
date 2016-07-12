class Map
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial
  property :created_at, DateTime
  property :updated_at, DateTime
  property :school_id, Integer
  property :train_field_id, Integer
  property :data, Text

  belongs_to :school, :model => 'School'
  belongs_to :train_field, :model => 'TrainField'

end

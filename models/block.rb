class Block
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial
  property :created_at, DateTime
  property :updated_at, DateTime
  property :school_id, Integer
  property :train_field_id, Integer
  property :name, String
  #1-5，倒车入库，侧方停车，直角转弯、半坡、S线
  property :type, Integer
  property :data, String

  belongs_to :school, :model => 'School'
  belongs_to :train_field, :model => 'TrainField'

end

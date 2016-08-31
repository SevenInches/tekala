class SchoolDevice
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial
  property :school_id, Integer
  property :device_id, Integer
  property :car_id, Integer
  property :deploy_at, Date
  property :created_at, DateTime
  property :updated_at, DateTime
end

class Enroll
  include DataMapper::Resource

  property :id, Serial
  property :school, String
  property :name, String
  property :phone, String
  property :created_at, DateTime
  property :updated_at, DateTime
end

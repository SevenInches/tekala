class Meeting
  include DataMapper::Resource

  property :id, Serial
  property :start_at, DateTime
  property :end_at, DateTime
  property :name, String
  property :desc, String
  property :created_at, DateTime

end

class School
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial
  property :city, String
  property :name, String
  property :address, String
  property :phone, String
  property :profile, Text
  property :is_vip, Integer
  property :is_open, Integer
  property :weight, Integer
  property :master, String
  property :logo, String
  property :found_at, Date
  property :latitude, String
  property :longitude, String
  property :config, Text
  property :note, String
  property :created_at, DateTime
  property :updated_at, DateTime
end

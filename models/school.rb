class School
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial
  property :city_id, Integer
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

  belongs_to :city

  has n, :products

  def city_name
    city.name
  end

end

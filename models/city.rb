#城市
class City
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial
  property :name, String
  property :keys, Integer


  def self.first_city_id(city)
    current = self.first(:name.like => "%#{city}%")
    current.id if current.present?
  end
end

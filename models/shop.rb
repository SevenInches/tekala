#门店
class Shop
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial
  property :created_at, DateTime
  property :updated_at, DateTime
  property :name, String
  property :address, String
  property :longitude, String
  property :latitude, String
  property :rent_amount, Integer
  property :area, Integer
  property :school_id, Integer
  property :contact_user, String
  property :contact_phone, String
end

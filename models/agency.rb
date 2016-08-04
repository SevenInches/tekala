class Agency
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial
  property :channel_id, Integer
  property :product_id, Integer
  property :amount, Integer
  property :created_at, DateTime
  property :updated_at, DateTime
  property :commission, Integer
  property :price, Integer
  property :school_name, String
  property :school_logo, String
  property :product_name, String

end
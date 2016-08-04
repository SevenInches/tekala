class Agency
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial
  property :channel_id, Integer
  property :product_id, Integer
  property :amount, Integer
  property :created_at, DateTime
  property :updated_at, DateTime

end
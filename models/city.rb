class City
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial
  property :name, String
  property :keys, Integer

  has n, :products
  has n, :schools

end

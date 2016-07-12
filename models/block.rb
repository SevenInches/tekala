class Block
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial
  property :created_at, DateTime
  property :updated_at, DateTime
  property :school_id, Integer
  property :field_id, Integer
  property :name, String
  property :type, Integer
  property :data, String
end

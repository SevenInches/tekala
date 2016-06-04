class UserGrown
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial
  property :user_id, Integer
  property :owner, String
  property :note, String
  property :created_at, DateTime

  belongs_to :user
  
end

class UserLogin
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial
  property :created_at, DateTime
  property :updated_at, DateTime
  property :school_id, Integer
  property :user_id, Integer
  property :os, Integer
  property :version, String
  property :device, Text
end

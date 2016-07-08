class Log
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial
  property :created_at, DateTime
  property :school_id, Integer
  property :role, Integer
  property :role_id, Integer
  property :type, Integer
  property :content, String
  property :target_name, String
  property :target_id, Integer
end

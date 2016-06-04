class TmpLicense
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial
  property :name, String
  property :sex, Integer
  property :url, String
  property :created_at, DateTime
end

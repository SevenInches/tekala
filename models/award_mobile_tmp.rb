class AwardMobileTmp
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial
  property :mobile, String
  property :vaild_code, String
  property :created_at, DateTime
  property :has_use, Integer, :default => 0

  
end

class AppLaunchAd
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial
  property :created_at, DateTime
  property :updated_at, DateTime
  property :start_time, DateTime
  property :end_time, DateTime
  property :cover_url, String
  property :type, String
  property :route, String
  property :status, Integer
  property :value, String
end

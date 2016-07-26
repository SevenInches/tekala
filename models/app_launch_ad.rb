class AppLaunchAd
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial
  property :created_at, DateTime
  property :updated_at, DateTime
  property :start_time, DateTime
  property :end_time, DateTime
  property :cover_url, String
  property :type, Integer
  property :route, String
  property :status, Integer
  property :value, String
  #0=>所有all、1=>学员student、2=>教练teacher、3=>驾校school、4=>门店shop、5=>渠道channel
  property :channel, Integer

end

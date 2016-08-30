#app首页广告
class AppHomeAd
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial
  property :created_at, DateTime
  property :updated_at, DateTime
  property :cover_url, String
  property :type, String
  property :route, String
  property :value, String
  property :status, Integer
  property :index, Integer
  property :school_id, Integer
end

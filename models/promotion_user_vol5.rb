class PromotionUserVol5
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial
  property :name, String
  property :mobile, String
  property :photo, String
  property :wechat_name, String
  property :wechat_avatar, String
  property :wechat_unionid, String
  property :score, Integer, :default => 0
  property :created_at, DateTime
end

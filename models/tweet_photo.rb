#动态图片
class TweetPhoto
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial
  property :tweet_id, Integer
  property :user_id, Integer
  property :url, String
  property :created_at, DateTime

  
end

class TweetLike
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial
  property :tweet_id, Integer
  property :user_id, Integer
  property :created_at, DateTime
end

class TweetComment
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial
  property :user_id, Integer
  property :tweet_id, Integer
  property :content, Text
  property :reply_user_id, Integer
  property :created_at, DateTime

  belongs_to :user, :model => "User", :child_key => 'user_id'

  belongs_to :reply_user, :model => "User", :child_key => 'reply_user_id' 

  
end

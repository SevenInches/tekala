class Message
  include DataMapper::Resource

  property :id, Serial
  property :user_id, Integer
  property :reply_user_id, Integer
  property :from_user_id, Integer
  property :tweet_id, Integer
  property :content, Text
  property :type, String
  property :status, Integer #0是未读 1为已读
  property :created_at, DateTime

  belongs_to :from_user, :model => 'User', :child_key =>'from_user_id'
  belongs_to :reply_user, :model => 'User', :child_key =>'reply_user_id'
end

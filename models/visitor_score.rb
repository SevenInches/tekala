class VisitorScore
  include DataMapper::Resource

  property :id, Serial
  property :visitor_id, Integer
  property :score, Integer
  property :wechat_name, String
  property :wechat_unionid, String
  property :sex, Integer
  property :city, String
  property :created_at, DateTime

  belongs_to :visitor
end

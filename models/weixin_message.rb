class WeixinMessage
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial
  property :title, String
  property :desc, String
  property :pic, String
  property :url, String
  property :weight, Integer
  property :open, Integer, :default =>1
  property :created_at, DateTime

end

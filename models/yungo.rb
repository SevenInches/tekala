class Yungo
  include DataMapper::Resource

  property :id, Serial
  property :name, String
  property :num, Integer
  property :status, Integer
  property :result_name, String
  property :result_unionid, String
  property :result_openid, String
  property :result_avatar, String
  property :created_at, DateTime

  has n, :yungo_logs
  def yungo_count 
    yungo_logs.count
  end
end

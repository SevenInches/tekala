class WeixinMenu
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial
  property :name, String
  property :url, String
  property :parent, Integer
  property :type, String
  property :created_at, DateTime
end

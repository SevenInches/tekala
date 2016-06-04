class SysConfig
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial
  property :cover_url, String
  property :show_ad, Integer
  property :url, String
  property :force, Integer
  property :version, String
end

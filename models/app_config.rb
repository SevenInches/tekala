class AppConfig
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial
  property :city, String, :default => '0755'
  property :name, String
  property :icon, String
  property :open, Integer, :default => 1
  property :weight, Integer
  property :value, String
  property :type, String, :default => 'web'
end

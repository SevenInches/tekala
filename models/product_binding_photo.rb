class ProductBindingPhoto
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial
  property :url, String
  property :product_binding_id, Integer
  property :created_at, DateTime

  belongs_to :product_binding
  
  def resource_url
    CustomConfig::QINIUURL + url.to_s
  end
  
end

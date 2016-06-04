class BusinessChannel
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial
  property :type, Integer
  property :name, String
  property :mobile, String
  property :address, String
  property :photo, String, :auto_validation => false
  property :note, String
  property :quantity, Integer
  property :created_at, DateTime

  mount_uploader :photo, BusinessChannelPhoto

  def photo_url
     photo && photo.url ? CustomConfig::HOST + photo.url : ''
  end
  def photo_thumb_url
     photo.thumb && photo.thumb.url ? CustomConfig::HOST + photo.thumb.url : ''
  end 
  
end

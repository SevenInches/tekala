class News
  include DataMapper::Resource

  property :id, Serial
  property :title, String
  property :tagline, Text,  :auto_validation => false, :lazy => false
  property :content, Text, :lazy => false
  property :pv, Integer, :default => 0

  property :photo, String, :auto_validation => false

  property :created_at, DateTime

  mount_uploader :photo, NewsPhoto

  def photo_thumb_url
    photo.thumb && photo.thumb.url ? CustomConfig::HOST + photo.thumb.url : ''
  end 

  def photo_url
    photo && photo.url ? CustomConfig::HOST + photo.url : ''
  end
end

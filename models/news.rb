#新闻
class News
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial
  property :title, String
  property :tagline, Text,  :auto_validation => false, :lazy => false
  property :content, Text, :lazy => false
  property :pv, Integer, :default => 0
  property :view_count, Integer, :default => 0
  property :created_at, DateTime
  property :school_id, Integer

  property :photo, String, :auto_validation => false

  mount_uploader :photo, NewsPhoto

  belongs_to :school

  def photo_thumb_url
    photo.thumb && photo.thumb.url ? CustomConfig::HOST + photo.thumb.url : ''
  end 

  def photo_url
    photo && photo.url ? CustomConfig::HOST + photo.url : ''
  end
end

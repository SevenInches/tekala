# -*- encoding : utf-8 -*-
class Ad
  include DataMapper::Resource

  property :id, Serial
  property :title, String
  property :image, String, :auto_validation => false
  property :value, String
  property :type, String
  property :pv, Integer, :default => 0
  property :created_at, DateTime

  mount_uploader :image, AdImage

  def image_thumb_url
    image.thumb && image.thumb.url ? CustomConfig::HOST + image.thumb.url : ''
  end 

  def image_url
    image && image.url ? CustomConfig::HOST + image.url : ''
  end

  def format_date
    created_at.strftime('%Y-%m-%d')
  end

 

end

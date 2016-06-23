class Product
  include DataMapper::Resource

  property :id, Serial
  property :city_id, Integer
  property :name, String
  property :price, Integer #单位 分
  property :detail, Text
  property :deadline, Date, :default => '2050-01-01' #截止日期
  property :created_at, DateTime
  property :updated_at, DateTime
  property :show, Integer, :default => 0
  property :photo, String, :auto_validation => false

  property :info_photo, String, :auto_validation => false
  property :exam_two_standard, Integer, :default => 0
  property :exam_three_standard, Integer, :default => 0
  property :total_quantity, Integer, :default => 0
  #"c1"=>1,"c2"=>2
  property :exam_type, Integer, :default => 0

  mount_uploader :photo, ProductPhoto
  mount_uploader :info_photo, ProductInfoPhoto

  has n, :users, :model => 'User'

  belongs_to :school

  belongs_to :city

  def city_name
    city.name
  end

  def photo_thumb_url
     photo.thumb && photo.thumb.url ? CustomConfig::HOST + photo.thumb.url : ''
  end

  def photo_url
     photo && photo.url ? CustomConfig::HOST + photo.url : ''
  end

  def info_photo_thumb_url
     info_photo.thumb && info_photo.thumb.url ? CustomConfig::HOST + info_photo.thumb.url : ''
  end

  def info_photo_url
     info_photo && info_photo.url ? CustomConfig::HOST + info_photo.url : ''
  end

  #产品介绍
  def link
    CustomConfig::HOST + "/api/v2/product_info?product_id=#{id}"
  end

  def info_img 

  end

  def can_buy 
    show == 1 && deadline > Date.today
  end

end

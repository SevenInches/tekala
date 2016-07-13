class Product
  include DataMapper::Resource

  property :id, Serial
  property :name, String
  property :price, Integer
  property :detail, Text
  property :deadline, Date, :default => '2050-01-01'                  #截止日期
  property :created_at, DateTime
  property :updated_at, DateTime
  property :photo, String, :auto_validation => false                  #图片
  property :description, String                                       #描述
  property :introduction, Text                                        #简介

  property :info_photo, String, :auto_validation => false             #简介图片
  property :exam_two_standard, Integer, :default => 0                 #科二标准时长
  property :exam_three_standard, Integer, :default => 0               #科三标准时长
  property :total_quantity,  Integer, :default => 0                   #限制总学时
  #"c1"=>1,"c2"=>2
  property :exam_type, Integer, :default => 0                         #驾考类型

  property :school_id, Integer, :default => 0

  property :color, String                                             #颜色??
  property :city_id, Integer, :default => 0
  property :show, Boolean, :default => false                          #是否展示

  belongs_to :city

  belongs_to :school

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
    CustomConfig::HOST + "/api/v1/product_info?product_id=#{id}"
  end

  def self.colors
    {"紫色" => '#967ADC', "橙色" => "#EE6439", '蓝色' => '#4A89DC', '绿色' => '#8CC152'}
  end

  def can_buy 
    show == 1 && deadline > Date.today if deadline.present?
  end

end

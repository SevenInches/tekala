#产品
class Product

  include DataMapper::Resource

  property :id, Serial
  property :name, String, :default => ''
  property :price, Integer, :default => 0
  property :commission, Integer, :default => 0 # 代理佣金
  property :detail, Text, :default => ''
  property :deadline, Date                  #截止日期
  property :created_at, DateTime
  property :updated_at, DateTime
  property :photo, String, :auto_validation => false                  #图片
  property :description, String, :default => ''                       #描述
  property :introduction, Text, :default => ''                        #简介

  property :info_photo, String, :auto_validation => false, :default => ''  #简介图片

  #"c1"=>1,"c2"=>2
  property :exam_type, Integer, :default => 0                         #驾考类型

  property :school_id, Integer, :default => 0

  property :color, String, :default => ''                             #颜色
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

  def self.demo
    markdown = "|返回字段|字段的值|注解|\n|:-:|:-:|:-:|"
    demo = self.new
    demo.attributes.each do |key, value|
      if key == 'exam_type'
        note = 'c1=>1,c2=>2'
      else
        note = ''
      end
      line = "\n|#{key}|#{value}|#{note}|"
      markdown += line
    end
     doc = Maruku.new(markdown)
     return doc.to_html_document
  end

end

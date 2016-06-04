class Article
  include DataMapper::Resource

  property :id, Serial
  property :title, String
  property :content, Text, :length => 500000, :default => ''
  property :tag, String
  property :author, String
  property :url, String, :auto_validation => false
  property :description, String
  property :read_count, Integer, :default => 0
  property :type, Integer, :default => 0
  property :city, String, :default => '0755'
  property :created_at, DateTime

  mount_uploader :url, ArticleUrl

  def self.city 
    {'深圳' => '0755', "武汉" => '027', "重庆" => '023'}
  end

  def city_word

    case self.city
    when '0755'
      '深圳'
    when  '027'
      '武汉'
    when  '023'
      '重庆'
    end

  end
  def date_format 
  	created_at.strftime('%Y年%m月%d日')
  end

  def date_format_bg 
    created_at.strftime('%Y年%m月%d日 %H:%M')
  end

  def self.type
  {'报名' => 0, '科目一' => 1, '科目二' => 2, '科目三' => 3, '科目四' => 4, '长训' => 5, '隐藏' => 6} 
  end
  def type_word 
    case type 
    when 0
      '报名'
    when 1
      '科目一'
    when 2
      '科目二'
    when 3
      '科目三'
    when 4
      '科目四'
    when 5
      '长训'
    when 5
      '隐藏'
    else
      ''
    end
  end

  def thumb_url
     url.thumb && url.thumb.url ? CustomConfig::HOST + url.thumb.url : CustomConfig::HOST + '/images/icon180.png'
  end

end

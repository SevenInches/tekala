class Article
  include DataMapper::Resource

  property :id, Serial
  property :title, String
  property :content, Text, :length => 500000, :default => ''
  property :tag, String
  property :author, String
  property :url, String
  property :description, String
  property :read_count, Integer, :default => 0
  property :type, Integer, :default => 0
  property :city, String
  property :created_at, DateTime

  def date_format 
  	created_at.strftime('%Y年%m月%d日')
  end

  def date_format_bg 
    created_at.strftime('%Y年%m月%d日 %H:%M')
  end

end

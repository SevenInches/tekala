#消息卡片
class MessageCard
  include DataMapper::Resource

  HOME = 'http://t.tekala.cn/school/v1/'

  # property <name>, <type>
  property :id, Serial
  property :title, String
  property :school_id, Integer
  property :weight, Integer
  property :url, String
  property :click_num, Integer, :default => 0
  property :tag, String
  property :created_at, DateTime

  def date
    created_at.strftime('%y年%m月%d日') if created_at.present?
  end

end

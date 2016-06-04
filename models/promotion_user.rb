class PromotionUser
  include DataMapper::Resource

  attr_accessor :before_wechat_avatar, :before_wechat_unionid

  property :id, Serial
  property :user_id, Integer
  property :number, Integer, :unique => true
  property :normal_photo, String, :auto_validation => false
  property :meng_photo, String, :auto_validation => false
  property :score, Integer, :default => 0

  property :rank, Integer, :default => 0

  #科目1,2,3,4
  property :level, Enum[1, 2, 3, 4], :default => 1

  property :motto, String, :auto_validation => false
  property :created_at, DateTime
  property :updated_at, DateTime
  property :phase, Integer, :default => 16

  property :event_key, Integer
  property :wechat_avatar, String
  property :wechat_unionid, String

  has n, :promotion_scores, :model => 'PromotionScore', :child_key => :user_id, :parent_key => :user_id, :constraint => :destroy

  mount_uploader :normal_photo, UserNormalPhoto

  mount_uploader :meng_photo, UserMengPhoto

  mount_uploader :motto, UserMotto
  
  belongs_to :user

  after :create, :stats

  before :save do 
    self.before_wechat_avatar  = wechat_avatar
    self.before_wechat_unionid = wechat_unionid
  end
  
  after :save do 

    if !wechat_unionid.nil? && self.before_wechat_unionid.nil?
      user_count = PromotionUser.all(:wechat_unionid => wechat_unionid).count

      if user_count < 2 

       promotion_channel = PromotionChannel.first(:from => wechat_unionid)
       return if promotion_channel.nil?
       data = ChannelData.first_or_create(:event_key => promotion_channel.event_key, :date => Date.today.strftime('%Y%m%d'))
       data.submit_count = data.submit_count.to_i + 1
       data.order_count  = data.order_count.to_i + 1
       data.save

      end
      
    end
    
  end

  def stats
    #统计来源
    return if wechat_unionid.nil? 

    user_count = PromotionUser.all(:wechat_unionid => wechat_unionid).count
    if user_count < 2 
      promotion_channel = PromotionChannel.first(:from => wechat_unionid)

      return if promotion_channel.nil?
      
      data = ChannelData.first_or_create(:event_key => promotion_channel.event_key, :date => Date.today.strftime('%Y%m%d'))
      data.submit_count = data.submit_count.to_i + 1
      data.order_count  = data.order_count.to_i + 1
      data.save
    end

  end

  def date_fromat
    created_at.strftime('%Y-%m-%d')
  end

  def normal_photo_thumb_url
     normal_photo.thumb && normal_photo.thumb.url ? CustomConfig::HOST + normal_photo.thumb.url : ''
  end 

  def normal_photo_url
     normal_photo && normal_photo.url ? CustomConfig::HOST + normal_photo.url : ''
  end

  def meng_photo_thumb_url
     meng_photo.thumb && meng_photo.thumb.url ? CustomConfig::HOST + meng_photo.thumb.url : ''
  end 

  def meng_photo_url
     meng_photo && meng_photo.url ? CustomConfig::HOST + meng_photo.url : ''
  end

  def motto_thumb_url
     motto.thumb && motto.thumb.url ? CustomConfig::HOST + motto.thumb.url : ''
  end 

  def motto_url
     motto && motto.url ? CustomConfig::HOST + motto.url : ''
  end

  def self.get_level
    {:龙岗 => 1, :宝安 => 2, :罗湖 => 3, :福田 => 4, :南山 => 5, :盐田 => 6, :其他 => 0}
  end

  def level_word
    case level
    when 1
      return '科目一'
    when 2
      return '科目二'
    when 3
      return '科目三'
    when 4
      return '文明考'
    end
  end

  def lik_count
    promotion_scores.all(:type =>1).count
  end


end

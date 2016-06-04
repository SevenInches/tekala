class PromotionInfoCollection
  include DataMapper::Resource

  property :id, Serial
  property :name, String
  property :mobile, String
  property :created_at, DateTime
  property :status, Integer
  property :note, String
  property :wechat_unionid, String
  property :wechat_avatar, String
  property :wechat_name, String

  after :create, :channel

  def channel
  	if !wechat_unionid.nil?
      promotion_channel = PromotionChannel.first(:from => wechat_unionid)
        if !promotion_channel.nil?
          data = ChannelData.first_or_create(:event_key => promotion_channel.event_key, :date => Date.today.strftime('%Y%m%d'))
          data.simply_submit = data.simply_submit.to_i + 1
          data.save
        end

      end
  end

  def created_at_format 
    created_at.strftime('%Y-%m-%d')
  end

end

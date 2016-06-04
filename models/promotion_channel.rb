class PromotionChannel
  include DataMapper::Resource

  property :id, Serial
  property :from, String
  property :created_at, DateTime
  property :event, String
  property :event_key, String

  after :create, :stats

  def stats
  	user_count = PromotionChannel.all(:from => from).count
  	if user_count < 2
  		data = ChannelData.first_or_create(:event_key => event_key, :date => Date.today.strftime('%Y%m%d'))
  		data.scan_count = data.scan_count.to_i + 1
  		data.save
  	end
  end

end
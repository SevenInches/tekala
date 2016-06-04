class ChannelData
  include DataMapper::Resource

  property :id, Serial
  property :channel_id, Integer
  property :event_key, Integer
  property :date, String
  property :scan_count, Integer, :default => 0
  property :simply_submit, Integer, :default => 0
  property :submit_count, Integer, :default => 0
  property :order_count, Integer, :default => 0
  property :pay_count, Integer, :default => 0
  property :created_at, DateTime

  belongs_to :channel , :model => "Channel", :child_key => 'event_key', :parent_key => 'event_key'

  def percent val
    return "0%" if scan_count == 0 || val.nil?
    "#{((val.to_f*100)/(scan_count)).round(2)}%"

  end

  def self.percent val, scan_count
    return "0%" if scan_count == 0 || val.nil?
    "#{((val.to_f*100)/(scan_count)).round(2)}%"

  end

  
end

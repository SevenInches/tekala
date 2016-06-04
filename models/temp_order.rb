class TempOrder
  include DataMapper::Resource
  # property <name>, <type>
  property :id, Serial
  property :book_time, DateTime
  property :name, String
  property :mobile, String
  property :created_at, DateTime
  property :has_sms, Boolean

  def book_time_format 
  	book_time.strftime('%Y-%m-%d %H:%M:%S')
  end

  def book_time_format_china 
    book_time.strftime('%m月%d日 %k点')
  end
end

class UserSchedule
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial
  property :user_id, Integer
  property :theme, String
  property :quantity, Integer
  property :book_time, DateTime
  property :status, Integer

  belongs_to :user, :model => 'User'

  def self.theme 
    {'车辆行驶准备'    => 0,
     '车辆基本操作'    => 1,
     '倒车入库'       => 2,
     '侧方停车'       => 3,
     '坡道停车和起步'  => 4,
     '曲线行驶'       => 5,
     '直角转弯'       => 6}

  end

  def theme_content
    case self.theme 
    when '0'
      return '车辆行驶准备'
    when '1'
      return '车辆基本操作'
    when '2'
      return '倒车入库'
    when '3'
      return '侧方停车'
    when '4'
      return '坡道停车和起步'
    when '5' 
      return '曲线行驶'   
    when '6'   
      return '直角转弯'   
    end
  end
end

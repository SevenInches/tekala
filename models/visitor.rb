class Visitor
  include DataMapper::Resource

  property :id, Serial
  property :name, String, :required => true, :messages => {:presence => '请填写姓名'}
  property :sex, Enum[ 0, 1], :default => 1, :required => true
  property :age, Integer, :required => true, :messages => {:presence => '请填写年龄'}
  property :mobile, String, :required => true, :unique => true, :messages => {:is_unique => "手机号已经存在",
                          :presence => '请填写联系电话'}
  property :area, Enum[ 1, 2, 3, 4, 5], :default => 1, :required => true
  property :industry, Enum[ 1, 2, 3, 4, 5], :default => 1, :required => true
  property :wechat_avatar, String
  property :wechat_unionid, String, :required => true, :unique => true, 
            :messages => {:is_unique => "您已经报名过了",
                          :presence => '请在微信打开此页面'} #微信唯一标识号
  property :score, Integer, :default => 0
  property :created_at, DateTime

  has n, :visitor_scores

  def thumb_avatar
    wechat_avatar.to_s.sub("/0", "/64")
    # 用户头像，最后一个数值代表正方形头像大小（有0、46、64、96、132数值可选，0代表640*640正方形头像），用户没有头像时该项为空
  end

  def avatar 
    wechat_avatar ? wechat_avatar : CustomConfig::HOST + '/images/icon180.png'
  end

  def self.get_sex
    return {'男'=>'1', '女'=>'0'}
  end

  def self.get_area
    return {'南山区'=>'1', '福田区'=>'2', '罗湖区'=>'3', '宝安区'=>'4', '龙岗区'=>'5'}
  end
  
  def self.get_industry
    return {'互联网'=>'1', '金融'=>'2', '公务员'=>'3', '学生'=>'4', '其他'=>'5'}
  end

  def set_sex
    case self.sex
    when 0
      return '女'
    when 1
      return '男'
    end
  end

  def set_area
    case self.area
    when 1
      return '南山区'
    when 2
      return '福田区'
    when 3
      return '罗湖区'
    when 4
      return '宝安区'
    when 5
      return '龙岗区'
    end
  end

  def self.chart_area(value)
    case value
    when 1
      return '南山区'
    when 2
      return '福田区'
    when 3
      return '罗湖区'
    when 4
      return '宝安区'
    when 5
      return '龙岗区'
    end
  end

  def set_industry
    case self.industry
    when 1
      return '互联网'
    when 2
      return '金融'
    when 3
      return '公务员'
    when 4
      return '学生'
    when 5
      return '其他'
    end
  end

  def self.chart_industry(value)
    case value
    when 1
      return '互联网'
    when 2
      return '金融'
    when 3
      return '公务员'
    when 4
      return '学生'
    when 5
      return '其他'
    end
  end
end

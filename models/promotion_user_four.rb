class PromotionUserFour
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial
  property :name, String
  property :tel, String, :required => true, :unique => true,
           :messages => {
              :presence  => "手机号不能为空",
              :is_unique => "该手机号已报名"
           }
  property :age, Integer
  property :company_id, Integer
  property :role, Enum[ 1, 2, 3], :default => 1
  property :local, Boolean
  property :area, Enum[ 0, 1, 2, 3, 4, 5], :default => 0
  property :wechat_avatar, String
  property :wechat_unionid, String
  property :score, Integer
  property :created_at, DateTime

  belongs_to :user
  has 1, :user, :model => 'User', :parent_key => 'tel', :child_key => 'mobile'

  belongs_to :company, :model => 'PromotionCompany', :parent_key => 'id', :child_key => 'company_id'

  def self.get_area
    {'南山' => 5, '龙岗' => 1, '宝安' => 2, '罗湖' => 3, '福田' => 4, '其他' => 0}
  end

  def self.get_role
    {'员工' => 1, "家人" => 2, '朋友' => 3}
  end

  def role_word 
    case self.role
    when 3
      return '朋友'
    when 2
      return '家人'
    else
      return '员工'
    end
  end

  def set_area
    case self.area
    when 1
      return '龙岗'
    when 2
      return '宝安'
    when 3
      return '罗湖'
    when 4
      return '福田'
    when 5
      return '南山'
    else
      return '其他'
    end
  end

  def avatar 
    wechat_avatar && !wechat_avatar.empty? ? wechat_avatar : CustomConfig::HOST + '/images/icon180.png'
  end

  def thumb_avatar 
    wechat_avatar && !wechat_avatar.empty? ? wechat_avatar+'64' : CustomConfig::HOST + '/images/icon180.png'
  end

  def date_format
    created_at.strftime('%Y-%m-%d %H:%M')
  end

  def test 
    tel
  end


end

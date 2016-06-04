class UserCycle
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial
  property :user_id, Integer
  property :level, Integer
  property :date, Date
  property :result, Integer
  property :note, String

  belongs_to :user, :model => 'User', :child_key => 'user_id'

  def color 
    level ||= 100
    case level
    when 20
      result >= 90 ? '' : 'red_point'
    when 40
      result >= 80 ? '' : 'red_point'
    when 70
      result >= 80 ? '' : 'red_point'
    when 90
      result >= 90 ? '' : 'red_point'
    end
  end

  def self.get_level_name(level)
    level_hash = Hash[
        0=>'退款',
        1=>'注册',
        2=>'付款',
        11=>'体检',
        12=>'拍照',
        13=>'资料收集齐全',
        14=>'录指纹,出流水',
        15=>'理论学习',
        20=>'科目一考试',
        40=>'科目二考试',
        60=>'长训',
        70=>'科目三考试',
        90=>'科目四考试',
        100=>'拿证'
    ]

    if level.nil?
      return level_hash
    else
      return level_hash[level]
    end
  end

end

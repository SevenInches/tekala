#用户考试记录
class UserCycle
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial
  property :user_id, Integer
  property :level, Integer
  property :date, Date
  property :result, Boolean, :default => 0
  property :note, String

  belongs_to :user

  def self.level_array
    {
        10=>'科目一',
        11=>'科目一(补考)',
        20=>'科目二',
        21=>'科目二(补考)',
        30=>'科目三',
        31=>'科目三(补考)',
        40=>'科目四',
        41=>'科目四(补考)',
        50=>'长训',
        51=>'长训(补考)'
    }
  end

  def result_word
    result.present? ? '通过' : '挂科'
  end

  def level_word
    if level.present?
      level_hash = UserCycle::level_array
      level_hash[level.to_i]
    end
  end

end

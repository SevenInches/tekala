class Push
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial
  property :message, String
  property :type, Integer, :auto_validation => false
  property :value, String
  property :channel_id, Integer, :auto_validation => false
  property :version, String
  property :school_id, Integer, :auto_validation => false
  property :user_status, Boolean, :auto_validation => false
  property :editions, String, :auto_validation => false

  belongs_to :channel
  belongs_to :school

  def self.get_type(key=nil)
    words = {
        1 => '版本更新',
        2 => '活动消息',
        3 => '报名订单',
        4 => '约车订单',
        5 => '消息',
        6 => '动态'
    }
    if key.present?
      words[key]
    else
      words
    end
  end

  def self.get_user_status(key=nil)
    words = {
        0 => '未报名',
        1 => '已报名'
    }
    if !key.nil?
      key ? words[1] : words[0]
    else
      words
    end
  end

  def self.get_editions(key=nil)
    words = {
        1 => '学员版',
        2 => '教练版',
        3 => '驾校版',
        4 => '门店版',
        5 => '代理渠道版'
    }
    if key.present?
      words[key]
    else
      words
    end
  end

  def editions_name
    if editions.present?
      array = editions.split(":")
      names = []
      array.each do |a|
        names << Push.get_editions(a.to_i)
      end
      names.join(":")
    end
  end
end

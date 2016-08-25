#app推送广告
class AppLaunchAd
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial
  property :created_at, DateTime
  property :updated_at, DateTime
  property :start_time, DateTime
  property :end_time, DateTime
  property :cover_url, String
  property :type, Integer, :auto_validation => false
  property :route, String
  property :status, Boolean, :default => true, :auto_validation => false
  property :value, String, :default => '', :auto_validation => false
  #0=>所有all、1=>学员student、2=>教练teacher、3=>驾校school、4=>门店shop、5=>渠道channel
  property :channel, Integer


  def self.get_channel(key=nil)
    words = {
        0 => '所有',
        1 => '学员',
        2 => '教练',
        3 => '驾校',
        4 => '门店',
        5 => '渠道'
    }
    if key.present?
      words[key]
    else
      words
    end
  end

  def self.get_type(key=nil)
    words = {
        1 => 'web',
        2 => 'app'
    }
    if key.present?
      words[key]
    else
      words
    end
  end

  def status_word
    status ? '开放' : '关闭'
  end
end

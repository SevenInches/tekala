class Award
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial
  property :name, String
  property :num, Integer
  property :status, Integer, :default => 0
  property :start_code, Integer, :default => 100001
  property :total_time, Integer, :default => 0
  property :award_log_id, Integer
  property :result_name, String
  property :result_unionid, String
  property :result_openid, String
  property :result_avatar, String
  property :current_count, Integer, :default => 0
  property :created_at, DateTime

  has n, :award_logs, :constraint => :destroy

  def log_count 
    award_logs.count
  end

  def created_at_format
    created_at.strftime('%m-%d %H:%M:%S')
  end

  def success
    !award_log_id.nil?
  end

  def belongs_num 
    log = AwardLog.get(award_log_id) 
    log ? log.code : '未开奖'
  end

 
end

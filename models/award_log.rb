class AwardLog
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial
  property :user_id, Integer
  property :award_id, Integer
  property :code, Integer
  property :time_num, Integer
  property :wechat_avatar, String
  property :wechat_openid, String
  property :wechat_unionid, String
  property :type, String
  property :created_at, DateTime

  belongs_to :user, :model  => 'User'  
  belongs_to :award, :model => 'Award'  

  NUM  = 4800
  before :save do 
    self.time_num = created_at.to_i
    last_log      = AwardLog.last

    award = Award.last

    if award.nil?
      award = Award.new(:name => "第 1 期", :num => NUM)
      award.save
    end

    #车码增加
    self.code     = (last_log.nil? || award.current_count == 0 )  ? award.start_code : last_log.code + 1
    self.award_id = award.id

    award.current_count += 1
    award.total_time    += self.time_num
    award.save

  end

  after :save do 

    # 填写用户获奖的id和新增一期活动
    award = Award.last

    if award.current_count >= award.num
      #公布获奖
      award_num          =  (award.total_time%award.num) + award.start_code
      award.award_log_id =  AwardLog.first(:code => award_num).id
      award.save
      #新建一期
      award_count = Award.count + 1
      award = Award.new(:name => "第 #{award_count} 期", :num => NUM, :start_code => award.start_code+10000)
      award.save
    end

  end

  def type_word
    case type 
    when 'join'
      '<label class="label label-warning">参与</label>'
    else
      '<label class="label label-info">分享</label>'
    end
  end

  def created_at_format
    created_at.strftime('%m-%d %H:%M:%S')
  end

  def created_at_date_form
    created_at.strftime('%Y-%m-%d')
  end

  def created_at_time_form
    created_at.strftime('%H:%M:%S')
  end

  def wechat_avatar_thumb 
    wechat_avatar ? wechat_avatar.gsub(/\/0/, '/64') : ''
  end

  def user_name 
    user ? user.name : ''
  end

  
end

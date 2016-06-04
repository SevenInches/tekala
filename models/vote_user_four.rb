class VoteUserFour
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial
  property :wechat_unionid, String
  property :wechat_avatar, String
  property :company_id, Integer
  property :created_at, DateTime

  before :create, :score_increase 

  belongs_to :company, :model => 'PromotionCompany', :parent_key => 'id', :child_key => 'company_id'
  
  def score_increase 
  	company = PromotionCompany.get company_id
  	if company
  	company.score = 0 if company.score.nil?
    company.score = company.score + 1
    puts company.save ? "公司票数+1" : "公司票数+1失败"
    end
  end

  def avatar 
    wechat_avatar && !wechat_avatar.empty? ? wechat_avatar : CustomConfig::HOST + '/images/icon180.png'
  end

  def thumb_avatar 
    wechat_avatar && !wechat_avatar.empty? ? wechat_avatar+'64' : CustomConfig::HOST + '/images/icon180.png'
  end

end

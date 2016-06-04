class PromotionVol5VoteLog
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial
  property :wechat_avatar, String
  property :wechat_unionid, String
  property :wechat_name, String
  property :user_id, Integer
  property :created_at, DateTime

  belongs_to :promotion_user_vol5 , :model => "PromotionUserVol5", :child_key => 'user_id', :parent_key => 'id'

  after :create, :add_score 

  def add_score 
  	promotion_user_vol5.score += 1
  	promotion_user_vol5.save
  end
end

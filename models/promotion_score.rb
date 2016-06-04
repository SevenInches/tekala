class PromotionScore
  include DataMapper::Resource

  property :id, Serial
  property :user_id, Integer
  property :type, Integer #weixin 1, metting 2

  property :score, Integer
  property :wechat_avatar, String
  property :wechat_name, String
  property :wechat_unionid, String
  property :sex, Integer
  property :city, String
  property :created_at, DateTime

  belongs_to :promotion_user, :parent_key => 'user_id', :child_key => 'user_id'

  after :save, :add_score

  def add_score
    if user_id
      promotion_user.score += score
      promotion_user.save
    else

    end
  end

end

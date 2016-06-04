class PromotionCompany
  include DataMapper::Resource

  property :id, Serial
  property :name, String, :required => true, :unique => true,
           :messages => {
              :presence  => "请填写公司名称",
              :is_unique => "该公司已存在"
           }
           
  property :logo, String, :auto_validation => false
  property :desc, String
  property :sort, Integer
  property :count, Integer, :default => 0
  property :score, Integer, :default => 0
  property :created_at, DateTime

  mount_uploader :logo, PromotionCompanyLogo

  has n, :users, :model => 'PromotionUserFour', :child_key => :company_id, :parent_key => :id, :constraint => :destroy
 
  has n, :votes, :model => 'VoteUserFour', :child_key => :company_id, :parent_key => :id, :constraint => :destroy


  def logo_thumb_url
     logo.thumb && logo.thumb.url ? CustomConfig::HOST + logo.thumb.url : CustomConfig::HOST + '/images/icon180.png'
  end 

  def logo_url
     logo && logo.url ? CustomConfig::HOST + logo.url : ''
  end
  
  def avatar 
    wechat_avatar && !wechat_avatar.empty? ? wechat_avatar : CustomConfig::HOST + '/images/icon180.png'
  end

  
end

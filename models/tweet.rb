#学员动态
class Tweet
  include DataMapper::Resource
  # property <name>, <type>
  property :id, Serial
  property :user_id, Integer
  property :content, Text, :required => true, :lazy => false,
                           :messages =>{:presence  => "写点什么吧~~" }

                           
  property :created_at, DateTime
  property :updated_at, DateTime
  
  property :city, String, :default => '0755'


  belongs_to :user

  has n, :tweet_photos

  has n, :tweet_comments, :constraint => :destroy

  has n, :tweet_likes
  
  def photos
  	 tweet_photos.map(&:url).map{ |val| val.present? ? CustomConfig::QINIUURL + val : '' };
  end

  def has_like(user_id=0)
  	tweet_likes.first(:user_id => user_id).nil? ? false : true
  end

  def comment_count
  	tweet_comments.count
  end

  def photo_count 
    tweet_photos.count
  end

  def like_count
    tweet_likes.count
  end


  # 添加日志
  def add_log(type, content, target=nil)
    user.add_log(type, content, target)
  end

end

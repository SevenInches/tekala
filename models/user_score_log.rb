class UserScoreLog
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial
  property :score, Integer
  property :user_id, Integer
  property :invite_user_id, Integer
  property :before_score, Integer
  property :after_score, Integer
  property :type, String
  property :note, String
  property :created_at, DateTime

  belongs_to :user

  after :create, :add_user_score 

  def add_user_score 
  	user.score = 0 if user.score.nil?
  	user.score = user.score + score
  	user.save
  end

  def created_at_format 
    created_at.strftime('%Y-%m-%d')
  end

  def invite_user_name
    user = User.get(invite_user_id)
    user ? user.name : ''
  end
end

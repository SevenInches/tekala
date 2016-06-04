class Recommend
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial
  property :name, String
  property :signup_counts, Integer
  property :enrolled_count, Integer
  property :user_id, Integer
  property :status, Integer
  belongs_to :user

  #同步user数据
  def self.synchronous_data
    User.all.each do |user|
      Recommend.first_or_create(:user_id => user.id)
    end
  end

  def refresh_counts
    signup_users        = User.all(:from_code => self.user.invite_code)
    enrolled_users      = User.all(:from_code => self.user.invite_code, :type => 1)
    self.name           = self.user.name
    self.signup_counts  = signup_users.count
    self.enrolled_count = enrolled_users.count
    self.save
  end

  def self.sort_icon(param)
    case param
    when 'desc'
      return 'sort-desc'
    when 'asc'
      return 'sort-asc'
    else
      return 'sort'
    end
  end
end

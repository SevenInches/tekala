class Group
  include DataMapper::Resource

  property :id, Serial
  property :count, Integer
  property :price, Float
  property :discount, Float
  property :note, String
  property :by_user_id, Integer
  property :deadline, DateTime
  property :created_at, DateTime

  belongs_to :user, :model => 'User', :child_key => 'by_user_id'

  has n, :user_groups, :model => 'UserGroup', :child_key => 'group_id'

  def member_count
    user_groups.count
  end

  def member_count_with_pay
    count = 0
    user_groups.each do |current_ug|
      count += 1 if current_ug.has_paid
    end
    count
  end

  def member_avatar_arr
    user_groups.map(&:wechat_avatar)
  end

  def self.group_type 
  	[
  	  {count: 	 2,
       discount: 50,
  		 price:    200.0,
       color:    '#4FC1E9'},
  		{count: 	 4,
       discount: 100,
  		 price:    200.0,
       color:    '#8CC152'},
  		{count: 	 8,
       discount: 200,
  		 price:    200.0,
       color:    '#ED5565'}
  	 ]
  end

  def self.current count
    case count.to_i
    when 4
      {count:    4,
       discount: 100,
       price:    200.0,
       color:    '#8CC152'}
    when 8
      {count:    8,
       discount: 200,
       price:    200.0,
       color:    '#ED5565'}
    else
      {count:    2,
       discount: 50,
       price:    200.0,
       color:    '#4FC1E9'}
    end
  end

  def created_at_format
    created_at.strftime('%Y-%m-%d %H:%M') 
  end

end

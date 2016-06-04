class City
  include DataMapper::Resource

  property :id, Serial
  property :num, String #区号
  property :name, String #城市名称
  property :goal, Integer #城市名称
  property :created_at, DateTime

  has n, :products, :model => 'Product', :child_key => 'city', :parent_key => 'num'
  has n, :pay_type, :model => 'Product', :child_key => 'city', :parent_key => 'num'

  def created_at_format 
  	created_at.strftime("%Y-%m-%d")
  end

  def user_count
    User.count(:city=>num)
  end

  def teacher_count
    Teacher.count(:city=>num)
  end

  def field_count
    TrainField.count(:city=>num)
  end

  def goal_left
    goal.to_i - User.vip.count(:city=>num)
  end

end

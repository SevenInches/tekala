class TrainField
  include DataMapper::Resource
  attr :distance, true
  # property <name>, <type>
  property :id, Serial
  property :name, String
  property :address, String
  property :longitude, String, :default => '0.0'
  property :latitude, String, :default => '0.0'
  property :remark, String
  property :count, Integer, :default => 0
  property :type, Enum[0, 1, 2], :default => 0
  property :display, Boolean, :default => true

  property :area, Integer, :default => 0

  property :city_id, Integer

  property :open, Integer, :default => 1
  property :c1, Integer, :default => 0
  property :c2, Integer, :default => 0
  property :users_count, Integer, :default => 0
  property :orders_count, Integer, :default => 0

  property :good_tags, String, :default => ''
  property :bad_tags, String, :default => ''
  property :subject, Integer, :default => 2
  property :school_id, Integer,:default => 0
  
  has n, :teachers, 'Teacher', :through => :teacher_field, :via => :teachers

  has n, :users

  belongs_to :school

  belongs_to :city


  def city_name
    city.name
  end

  def area_name
    City.get(area).name
  end

  def teacher_count
    count
  end

  def exam_type_count(type = 'c1')
    type.downcase == 'c1' ? c1 : c2
  end

  def self.type 
    {'挂靠/直营' => 0, "挂靠" => 1, '直营' => 2}
  end

  def type_word 
    case type
    when 1
    return '挂靠'
    when 2
    return '直营'
    else
    return '挂靠/直营'
    end 
  end

  def self.city
    return {'深圳' => '0755', '武汉' => '027', '重庆' => '023'}
  end

  def city_name
    case self.city
    when '0755'
      return '深圳'
    when '027'
      return '武汉'
    when '023'
      return '重庆'
    end
  end
  def self.open
    return {'开' => 1, '关' => 0}
  end
  def update_users_and_orders
    orders = Order.all(:status => Order::pay_or_done, :train_field_id => id, :type => 0)
    users = orders.all(:fields => [:user_id], :unique => true).to_a
    self.users_count = users.count
    self.orders_count = orders.count
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

  def self.subject 
    {'科目二' => 2, '科目三' => 3}
  end

  def subject_word 
    case subject 
    when 2
      '科目二'
    when 3
      '科目三'
    else 
      ''
    end

  end


end

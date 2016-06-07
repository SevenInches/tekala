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
   #   {:龙岗 => 1, :宝安 => 2, :罗湖 => 3, :福田 => 4, :南山 => 5, :盐田 => 6, :其他 => 0}
  property :area, Integer, :default => 0

  property :city, String, :default => '0755'
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

  def self.get_area(city)
    case city
    when '0755'
      {'福田区' => 440304, '罗湖区' => 440303, 
        '南山区' => 440305, '盐田区' => 440308, 
        '宝安区' => 440306, '龙岗区' => 440307, 
        '光明新区' => 440311, '龙华新区' => 440312, 
        '坪山新区' => 440313, '大鹏新区' => 440314}
    when '027'
      {'江岸区' => 420102, '江汉区' => 420103, 
        '硚口区' => 420104,'汉阳区' => 420105,
        '武昌区' => 420106,'青山区' => 420107,
        '洪山区' => 420111,'东西湖区' => 420112,
        '汉南区' => 420113,'蔡甸区' => 420114,
        '江夏区' => 420115,'黄陂区' => 420116,'新洲区' => 420117}
    when '023'
      { "江北区" => 400020,  "渝中区" =>400015, 
        "渝北区" =>401147,  "南岸区" =>400060, 
        "九龙坡区" =>400050,  "沙坪坝区" =>400030, 
        "北碚区" =>400700, "巴南区" =>401320, "大渡口" =>400080}
    end
  end

  def area_word
    if city == '0755'
      case self.area
      when 440307
        return '龙岗'
      when 440306
        return '宝安'
      when 440303
        return '罗湖'
      when 440304
        return '福田'
      when 440305
        return '南山'
      when 440308
        return '盐田'
      when 440311
        return '光明新区'
      when 440312
        return '龙华新区'
      else
        return '其他'
      end
    else
      case self.area
      when 420102
        return '江岸区'
      when 420103
        return '江汉区'
      when 420104
        return '硚口区'
      when 440305
        return '汉阳区'
      when 420106
        return '武昌区'
      when 420107
        return '青山区'
      when 420111
        return '洪山区'
      when 420112
        return '东西湖区'
      when 420113
        return '汉南区'
      when 420114
        return '蔡甸区'
      when 420115
        return '江夏区'
      when 420116
        return '黄陂区'
      when 420117
        return '新洲区'
      else
        return '其他'

      end
    end
    
  end

  def self.area_word area
    case area
    when 1
      return '龙岗'
    when 2
      return '宝安'
    when 3
      return '罗湖'
    when 4
      return '福田'
    when 5
      return '南山'
    when 6
      return '盐田'
    when 7
      return '光明新区'
    when 8
      return '龙华新区'
    else
      return '其他'
    end
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

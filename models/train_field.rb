class TrainField
  include DataMapper::Resource
  attr :distance, true
  # property <name>, <type>
  property :id, Serial
  property :name, String
  property :address, String
  property :longitude, String, :default => '0.0'
  property :latitude, String, :default => '0.0'
  property :remark, String                                    #评语
  property :count, Integer, :default => 0                     #??

  property :type, Enum[0, 1, 2], :default => 0                 #类型,挂靠/直营
  property :display, Boolean, :default => true                 #展示

  property :area, Integer

  property :city_id, Integer

  property :open, Integer, :default => 1                        #开放
  property :c1, Integer, :default => 0                          #应该是要去掉的
  property :c2, Integer, :default => 0                          #应该是要去掉的
  property :users_count, Integer, :default => 0                 #学员数量
  property :orders_count, Integer, :default => 0                #订单数量

  property :good_tags, String                                   #优点标签
  property :bad_tags, String                                    #缺点标签
  property :subject, Integer, :default => 2                     #科目二/科目三
  property :school_id, Integer,:default => 0
  
  has n, :teachers, 'Teacher', :through => :teacher_field, :via => :teachers

  belongs_to :school

  belongs_to :city


  def city_name
    city.nil? ? '--' : city.name
  end

  def area_name
    City.get(area).name if area.present? && area.to_i!= 0
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

  def teacher_num
    teachers.count
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

  def self.open
    return {'开' => 1, '关' => 0}
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


end

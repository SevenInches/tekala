class School
  include DataMapper::Resource
  require 'chinese_name'

  # property <name>, <type>
  property :id, Serial
  property :city_id, Integer
  property :name, String
  property :address, String
  property :phone, String
  property :profile, Text
  property :is_vip, Integer
  property :is_open, Integer
  property :weight, Integer
  property :master, String
  property :logo, String
  property :found_at, Date
  property :latitude, String
  property :longitude, String
  property :config, Text
  property :note, String
  property :created_at, DateTime
  property :updated_at, DateTime

  belongs_to :city

  after :create do |school|
    tid = school.demo_teacher
    fid = school.demo_train_field
    TeacherTrainField.new(:teacher_id=>tid, :train_field_id=>fid).save
  end

  def city_name
    city.nil? ? '--' : city.name
  end

  def demo_teacher
    names = ChineseName.generate(num = 3)
    teacher_array = []
    names.each do |name|
      new_teacher = Teacher.new(:password=>'123456', :open=>1, :status_flag=>2, :exam_type=>4)
      new_teacher.name = name[0]
      new_teacher.sex = (name[1]=='女')? 0 : 1
      new_teacher.age = Date.today.year - name[2].to_i
      new_teacher.school_id = id
      new_teacher.mobile = '138'+rand.to_s[2..9]
      if new_teacher.save
        teacher_array.push(new_teacher.id)
      end
    end
    teacher_array
  end

  def demo_train_field
    field = TrainField.new(:display=>1,:open=>1)
    field.name = self.generate_field
    field.city_id = city_id
    field.school_id = id
    field.save
    field.id
  end

  def generate_field
    first_names = %w(春 夏 秋 东 梅 兰 竹 菊 东 南 西 北 人民 解放 民主 团结 中山 少年 北京 上海 天津 南京 凤凰)
    first = first_names.sample
    last_names = %w(路 村 湖 山 庙 公园 体育馆 门 宫 庄 里 桥 科技园 大街)
    last = last_names.sample
    first+last+'训练场'
  end

end

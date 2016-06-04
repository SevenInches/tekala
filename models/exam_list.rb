class ExamList
  include DataMapper::Resource

  property :id, Serial
  property :exam_time, DateTime  #考试日期
  property :num, String          #流水号
  property :id_card, String      #身份证号码
  property :section, String      #场次
  property :name, String         #名字
  property :drive_school, String #驾校名字
  property :register, DateTime   #登记日期
  property :allow_exam, DateTime   #登记周期
  property :wait_value, Integer  #等待时间
  property :exam_count, Integer  #考试次数
  property :car_type, String     #准驾车型
  property :section_name, String #场次名称

end

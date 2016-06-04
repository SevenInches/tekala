class TeacherWeekPay
  include DataMapper::Resource
  # property <name>, <type>
  property :id, Serial
  property :teacher_id, Integer
  property :order_count, Integer
  property :c1_hours, Integer
  property :c2_hours, Integer
  property :money, Float
  property :allowance_money, Float
  property :total, Float
  property :should_pay, Float
  property :has_sms, Boolean
  property :has_pay, Boolean
  property :date_remark, String
  property :created_at, DateTime

  belongs_to :teacher
  
end

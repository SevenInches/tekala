class CalculateResults
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial
  property :num, String
  property :name, String
  property :signup_at, Date
  property :car_type, String
  property :wait_value, Integer
  property :cal_exam_date, Date
  property :section_name, String
  property :register_cycle, Date
  property :rate, Float
  property :number, Integer
  property :rank, Integer
  property :mobile, String
  property :id_card, String
  property :user_id, Integer
  property :created_at, DateTime
  property :updated_at, DateTime
end

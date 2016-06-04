class SecondSubList
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial
  property :num, String
  property :id_card, String
  property :section, String
  property :name, String
  property :drive_school, String
  property :register_time, DateTime
  property :register_cycle, Date
  property :allow_exam, DateTime
  property :wait_value, Integer
  property :count, Integer
  property :exam_type, String
  property :section_name, String
  property :status, Integer
end

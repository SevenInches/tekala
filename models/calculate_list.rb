class CalculateList
  include DataMapper::Resource

  property :id, Serial
  property :name, String
  property :id_card, String
  property :start_date, Date
  property :end_date, Date
  property :exam_type, String
  property :section, String
  property :mobile, String
  property :status, Integer

end

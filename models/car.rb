class Car
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial
  property :number, String
  property :identify, String
  property :produce_year, Integer
  property :note, String
  property :school_id, Integer
  property :brand, String
  property :name, String
  #'未知'=>1, 'C1'=>2, 'C2'=>3, 'C1/C2'=>4
  property :exam_type, Integer

  belongs_to :school
  belongs_to :branch

end

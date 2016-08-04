class Check
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial
  property :car_id, Integer
  property :check_end, Date
  property :year_check_end, Date
  property :season_check_end, Date
  property :second_check_end, Date

  belongs_to :car
end

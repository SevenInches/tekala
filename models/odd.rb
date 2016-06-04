class Odd
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial
  property :car_type, String
  property :section_name, String
  property :rate, Float
  property :number, Integer
  property :created_at, DateTime
  property :updated_at, DateTime

  def updated_at_format
  	updated_at.strftime('%Y-%m-%d')
  end
end

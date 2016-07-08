class FinanceReport
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial
  property :created_at, DateTime
  property :updated_at, DateTime
  property :start_date, DateTime
  property :end_date, DateTime
  property :title, String
  property :income, Integer
  property :outgoings, Integer
  property :admin, String
  property :note, Text
  property :school_id, Integer
end

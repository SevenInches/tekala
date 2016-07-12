class FinanceCategory
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial
  property :school_id, Integer
  property :name, String
end

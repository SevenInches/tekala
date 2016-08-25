#财务信息
class Finance
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial
  property :created_at, DateTime
  property :updated_at, DateTime
  property :school_id, Integer
  property :type, Integer
  property :category_id, Integer
  property :content, String
  property :amount, Integer
  property :status, Integer
  property :admin, String
  property :admin_date, DateTime
end

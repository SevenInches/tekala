class Insure
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial
  property :effective_tm, DateTime
  property :order_id, String
  property :order_no, String
  property :expire_tm, DateTime
  property :pol_no, String
  property :amount, Integer
  property :error_desc, String
  property :response, Text
  property :premium, Float
  property :error_code, String
  property :request_code, String
  property :request, Text
  property :created_at, DateTime

  belongs_to :order
end

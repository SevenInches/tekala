class Signup
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial
  property :user_id, Integer
  property :teacher_id, Integer
  property :train_field_id, Integer
  property :school_id, Integer
  property :order_no, String
  property :amount, Float, :default => 0.0
  property :discount, Float, :default => 0.0
  property :pay_at, DateTime
  property :done_at, DateTime
  property :cancel_at, DateTime
  property :created_at, DateTime
  property :updated_at, DateTime
  property :ch_id, String
  property :city_id, Integer
  property :product_id, Integer
  property :pay_channel, String
  #0=>未付款,1=>已付款,2=>申请退款,3=>退款中
  property :status, Integer, :default => 0
  #1=>C1,2=>C2
  property :exam_type, Integer, :default => 1

  belongs_to :user
  belongs_to :teacher
  belongs_to :train_field
  belongs_to :product, :model => 'Product'
  belongs_to :school
  belongs_to :city

end

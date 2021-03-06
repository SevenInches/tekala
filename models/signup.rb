#报名订单
class Signup
  include DataMapper::Resource
  # property <name>, <type>
  property :id, Serial
  property :user_id, Integer
  property :teacher_id, Integer
  property :train_field_id, Integer
  property :school_id, Integer
  property :order_no, String
  property :amount, Float
  property :discount, Float
  property :pay_at, DateTime
  property :refund_at, DateTime
  property :cancel_at, DateTime
  property :created_at, DateTime
  property :updated_at, DateTime
  property :ch_id, String
  property :city_id, Integer
  property :product_id, Integer
  property :pay_channel, String
  property :channel_id, Integer

  #1=>未付款,2=>已付款,3=>退款中,4=>已退款
  property :status, Integer
  #1=>C1,2=>C2
  property :exam_type, Integer

  belongs_to :user
  belongs_to :teacher
  belongs_to :train_field
  belongs_to :product
  belongs_to :school
  belongs_to :city
  belongs_to :channel

  def status_word
    case self.status
      when 1
        return '待支付'
      when 2
        return '已支付'
      when 3
        return '退款中'
      when 4
        return '已退款'
    end
  end

  def status_color
    case self.status
      when 1
        return 'danger'
      when 2
        return 'success'
      when 3
        return 'info'
      when 4
        return 'warning'
    end
  end

  def product_name
    product.name if product.present?
  end
end
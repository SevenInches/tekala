#确认订单
class OrderConfirm
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial
  property :teacher_id, Integer
  property :user_id, Integer
  property :order_id, Integer
  #{"未选择" => 0, "接受" => 1, "拒绝" => 2} #mok 2015-08-13
  property :status, Integer
  property :start_at, DateTime
  property :end_at, DateTime
  property :created_at, DateTime

  belongs_to :user
  belongs_to :order
  belongs_to :teacher

  def status_word 
    case status 
    when 0
      '教练未响应是否接单'
    when 1
      '教练已接下订单'
    when 2
      '教练已拒绝该订单'
    end
  end

  def status_word_label 
    case status 
    when 0
      'warning'
    when 1
      'success'
    when 2
      'danger'
    end
  end

end

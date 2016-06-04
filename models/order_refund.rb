class OrderRefund
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial
  property :account_id, Integer
  property :re_id, String
  property :order_no, String
  property :amount, Integer
  property :charge, String
  property :failure_code, String
  property :respose, Text
  property :created_at, DateTime

  belongs_to :order, :parent_key => 'ch_id', :child_key => 'charge' 

  after :save, :send_sms

  def send_sms 
    if failure_code.nil? && order
      message = Sms.new(
                        :member_name => order.user.name, 
                        :order_no => order.order_no, 
                        :money => order.promotion_amount, 
                        :member_mobile => order.user.mobile)

      message.refund

    end
  end

  # 添加退款记录，data是json格式
  def self.add(data)
    refunds = OrderRefund.new 
    refunds.failure_code = data['failure_code']
    refunds.re_id        = data['id']
    refunds.amount       = data['amount']
    refunds.charge       = data['charge']
    refunds.respose      = data
    refunds.save
  end
  
end

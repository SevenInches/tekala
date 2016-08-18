require "net/https"

class OptMessage
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial
  property :title, String
  property :content, String
  property :receiver, String
  property :created_at, DateTime
 
  after :create, :push_message

  # 发送源，萌萌学车
  Source    = "s-a8bec505-0d3c-4210-abec-e5acadaa"

  # 接收频道
  # 接收渠道分类：管理admin | 财务money | 订单order | 武汉wuhan | 错误error
  Receiver  = {:admin => 'g-5d27db61-fd1c-40a1-bace-7a0319b4', 
              :money => 'g-4a5ae881-3211-4df8-b1e7-346efe5d',
              :order => 'g-32ccff11-8a21-414b-9837-854b5e4c',
              :wuhan => 'g-29e68962-ad8d-4ce2-bd87-a0cc1816',
              :error => 'g-6998a6d5-cac6-40c4-8955-ac60728f'}

  def self.daily_report
    # 深圳昨天注册人数
    sz_all_count  = Order.count(:city=>'0755', :type =>Order::VIPTYPE, :pay_at => (Date.yesterday..Date.today))
    # 深圳昨天付款人数
    sz_count      = Order.count(:city=>'0755', :status => Order.pay_or_done, :type =>Order::VIPTYPE, :pay_at => (Date.yesterday..Date.today))
    
    # 武汉昨天注册人人数
    wh_all_count  = Order.count(:city=>'027', :type =>Order::VIPTYPE, :pay_at => (Date.yesterday..Date.today))
    # 武汉昨天付款人数
    wh_count      = Order.count(:city=>'027', :status => Order.pay_or_done, :type =>Order::VIPTYPE, :pay_at => (Date.yesterday..Date.today))

    # 深圳今天练车小时数
    sz_teacher_count = Order.count(:city=>'0755', :status => Order::pay_or_done, :book_time => (Date.today..Date.tomorrow))
    
    # 武汉今天练车小时数
    wh_teacher_count = Order.count(:city=>'027', :status => Order::pay_or_done, :book_time => (Date.today..Date.tomorrow))
    
    content  = "日报 | 深圳昨天报名#{sz_all_count}人,付款#{sz_count}人, 今天约车#{sz_teacher_count}小时。武汉#{wh_all_count}|#{wh_count}|#{wh_teacher_count}"
    
    OptMessage.create(:title=>'日报', :content=>content, :receiver=>:order)

    #统计战报
    current_month = Date.today.strftime('%Y-%m-01 00:00:00').to_time
    next_month    = (Date.today + 1.months).strftime('%Y-%m-01 00:00:00').to_time
    
    sz_pay_count  = Order.count(:city=>'0755', :status => Order::pay_or_done, :type => Order::VIPTYPE, :pay_at => current_month..next_month)
    sz_aims       = 200

    wh_pay_count  = Order.count(:city=>'027', :status => Order::pay_or_done, :type => Order::VIPTYPE, :pay_at => current_month..next_month)
    wh_aims       = 160
    
    content = "战报 | 深圳#{Time.now.strftime('%m')}月付款#{sz_pay_count}人，目标#{sz_aims}人，完成率#{ (sz_pay_count/(sz_aims.to_f)*100).round(2) }%；武汉#{Time.now.strftime('%m')}月付款#{wh_pay_count}人，目标#{wh_aims}，完成率#{ (wh_pay_count/(wh_aims.to_f)*100).round(2) }%"
    OptMessage.create(:title=>'战报', :content=>content, :receiver=>:order)

  end

  def self.report(content, receiver=:admin)
    OptMessage.create(:title=>'日报', :content=>content, :receiver=>receiver)
  end

  def self.alert(content, receiver=:admin)
    OptMessage.create(:title=>'警告', :content=>content, :receiver=>receiver)
  end

  def self.money(content)
    OptMessage.create(:title=>'财务', :content=>content, :receiver=>:money)
  end

  def self.order(content, receiver=:admin)
    OptMessage.create(:title=>'订单', :content=>content, :receiver=>receiver)
  end
  
  # 使用AlertOver推送消息
  def push_message
    return if Padrino.env == :development

    receiver_id  = Receiver[receiver.to_sym]
    return if receiver_id.nil?

    url = URI.parse("https://api.alertover.com/v1/alert")
    req = Net::HTTP::Post.new(url.path)
    req.set_form_data({
      :source =>  Source,
      :receiver =>receiver_id,
      :content => content,
      :title =>   title,
    })
    res = Net::HTTP.new(url.host, url.port)
    res.use_ssl = true
    res.verify_mode = OpenSSL::SSL::VERIFY_PEER
    res.start {|http| http.request(req) }
  end

end

task :teacher_daily_pay => :environment do
  # Order::pay_become_finish
  teacher = Teacher.all(:pay_type => 'day' , :city => '0755')
  teacher.each do |t|

      yesterday   = Date.today - 1.days
      nex_date    = yesterday  + 1.days

      orders   = Order.all(:teacher_id => t.id, :type => Order::PAYTOTEACHER, :status => Order::pay_or_done, :order => :book_time.asc,:book_time => (yesterday..nex_date) )
      c2_hours = orders.all(:exam_type => 2).sum(:quantity).to_i
      c1_hours = orders.all(:exam_type.not => 2).sum(:quantity).to_i

      date_remark = yesterday.strftime('%Y%m%d')

      next if TeacherDailyPay.first(:date_remark => date_remark, :teacher_id => t.id ).present? || (c2_hours + c1_hours) <= 0
      daily_pay = TeacherDailyPay.new
    	daily_pay.teacher_id  = t.id
    	daily_pay.order_count = orders.count
    	daily_pay.c1_hours    = c1_hours
    	daily_pay.c2_hours    = c2_hours
    	daily_pay.money       = ((c2_hours + c1_hours) * t.price).to_i
    	daily_pay.allowance_money = (Order::C2_ALLOWANCE * c2_hours).to_i
    	daily_pay.total           = (daily_pay.money + daily_pay.allowance_money).to_i
    	daily_pay.should_pay      =  t.vip == 1 ?  (daily_pay.total * (1 - Order::REBATE)).to_i : (daily_pay.total).to_i
    	daily_pay.has_pay         = false
    	daily_pay.has_sms         = false
    	daily_pay.date_remark     = date_remark
    	daily_pay.save



  end
end
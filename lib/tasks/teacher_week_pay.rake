task :teacher_week_pay => :environment do
  # Order::pay_become_finish
  teacher = Teacher.all(:pay_type => 'week', :city => '0755')
  teacher.each do |t|

    today  = Date.today
    start_date = today - (today.wday - 1).days - 7.days
    end_date   = start_date + 7.days

    orders   = Order.all(:teacher_id => t.id, :type => Order::PAYTOTEACHER, :status => Order::pay_or_done, :order => :book_time.asc )
  	orders   = orders.all(:book_time => (start_date..end_date))

    c2_hours = orders.all(:exam_type => 2).sum(:quantity).to_i
    c1_hours = orders.all(:exam_type.not => 2).sum(:quantity).to_i

    date_remark = start_date.strftime('%Y%m%d') + (end_date-1.days).strftime('%Y%m%d')

    next if !TeacherWeekPay.first(:date_remark => date_remark, :teacher_id => t.id ).nil? || (c2_hours + c1_hours) <= 0
    week_pay = TeacherWeekPay.new
  	week_pay.teacher_id  = t.id
  	week_pay.order_count = orders.count
  	week_pay.c1_hours    = c1_hours
  	week_pay.c2_hours    = c2_hours
  	week_pay.money       = ((c2_hours + c1_hours) * t.price).to_i
  	week_pay.allowance_money = (Order::C2_ALLOWANCE * c2_hours).to_i
  	week_pay.total           = (week_pay.money + week_pay.allowance_money).to_i
  	week_pay.should_pay      =  t.vip == 1 ?  (week_pay.total * (1 - Order::REBATE)).to_i : (week_pay.total).to_i
  	week_pay.has_pay         = false
  	week_pay.has_sms         = false
  	week_pay.date_remark     = date_remark
  	week_pay.save

  end
end
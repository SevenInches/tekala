task :teacher_rank => :environment do
  # Order::pay_become_finish
  teacher = Teacher.all( :city => '0755',:pay_type   => 'week')
  
  last_month = Date.today - 1.months
  start_date = last_month.strftime('%Y-%m-01').to_date
  end_date   = Date.today.strftime('%Y-%m-01').to_date
  teacher.each do |t|
    orders = Order.all(:teacher_id => t.id, 
                       :type       => Order::PAYTOTEACHER, 
                       :status     => Order::pay_or_done,
                       :book_time  => (start_date..end_date) )

    #评论
    comment_count = orders.teacher_comment.count
    comment       = orders.teacher_comment.map(&:rate)

    score         = comment.inject(:+).to_f > 0 ? comment.inject(:+)/comment_count : 5
    total_score   = comment.inject(:+).to_f 
    rank = TeacherRank.first_or_create(:teacher_id  => t.id,
                                       :month       => start_date.strftime('%Y%m'),
                                       :type        => 'score',
                                       :total_score => total_score)
    rank.val  = score
    rank.save

    #收入
    c1_moneys = orders.all(:exam_type.not => '2' ).map(&:quantity).inject(:+).to_i
    c2_moneys = orders.all(:exam_type     => '2' ).map(&:quantity).inject(:+).to_i
    total     = (c1_moneys*t.price + c1_moneys*(t.price+Order::C2_ALLOWANCE) )

    money = TeacherRank.first_or_create(:teacher_id => t.id,
                                       :month      => start_date.strftime('%Y%m'),
                                       :type       => 'money')
    money.val  = total
    money.save


  end


end
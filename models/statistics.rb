class Statistics
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial
  property :balance_date, Date
  property :users_count, Integer
  property :teachers_count, Integer
  property :hours, Integer
  property :pay, Integer
  property :status, Integer

  def self.balance(date)
    date = date.to_date
    start_at  = date.beginning_of_month
    end_at    = (date + 1.month).beginning_of_month
    orders    = Order.all(:status => Order::pay_or_done, :book_time => (start_at..end_at), :type => Order::PAYTOTEACHER)
    users     = orders.all(:fields => [:user_id], :unique => true).to_a
    teachers  = orders.all(:fields => [:teacher_id], :unique => true).to_a
    statistics = Statistics.first_or_create(:balance_date => start_at.to_date)
    statistics.users_count    = users.count
    statistics.teachers_count = teachers.count
    statistics.hours  = orders.sum(:quantity)
    statistics.pay    = orders.sum(:amount)
    statistics.save
  end
end

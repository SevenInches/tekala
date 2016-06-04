class UserStatistics
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial
  property :statistic_date, Date
  property :signup_counts, Integer
  property :pay_counts, Integer
  property :status, Integer

  def self.statistics(date)
    date = date.to_date
    year = date.year
    month = date.month
    start_at = year.to_s + '-' + month.to_s + '-01'
    end_at = year.to_s + '-' + (month + 1).to_s + '-01'
    users = User.all(:created_at => (start_at..end_at))
    orders = Order.all(:status => Order::pay_or_done, :pay_at => (start_at..end_at), :type => 1)
    pay_users = orders.all(:fields => [:user_id], :unique => true).to_a
    statistics = UserStatistics.first_or_create(:statistic_date => start_at.to_date)
    statistics.signup_counts = users.count
    statistics.pay_counts = pay_users.count
    statistics.save
  end
end

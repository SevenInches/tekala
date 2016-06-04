task :update_order_status => :environment do
  Order::pay_become_finish
end
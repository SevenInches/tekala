node(:status) { 'success' }
child(@agencies => :data){
      attributes :id, :name, :contact_phone, :logo, :config, :created_at, :updated_at, :total_earn, :signup_count, :pay_count
      node(:conversion_rate) { |val| val.user_num }
      node(:sales_this_month) { |val| val.sales_this_month(@channel.id) }
}
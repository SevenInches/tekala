node(:status) { 'success' }
child(@orders => :data){
      attributes :id, :user_id, :school_id, :product_id, :created_at, :updated_at, :commission
      node(:user_name) { |val| val.user_name(val.user_id) }
      node(:school_name) { |val| val.school_name(val.school_id) }
      node(:product_name) { |val| val.product_name(val.product_id) }
}
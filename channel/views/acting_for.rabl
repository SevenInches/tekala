node(:status) { 'success' }
child(@agencies => :data){
      attributes :id, :channel_id, :product_id, :amount, :created_at, :updated_at, :commission, :price, :school_name, :school_logo, :product_name
}
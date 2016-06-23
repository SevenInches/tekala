node(:status) { 'success' }
child(@school => :data){
      attributes :id, :city_name, :name, :address, :phone, :profile, :is_vip, :master,:logo, :found_at, :latitude, :longitude
      child(:products => :product){
         attributes :id, :name, :city_name, :price, :exam_type, :created_at
      }
}
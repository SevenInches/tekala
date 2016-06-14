node(:status) { 'success' }
child(@school => :data){
      attributes :id, :city, :name, :address, :phone, :profile, :is_vip, :master,:logo, :found_at, :latitude, :longitude
}
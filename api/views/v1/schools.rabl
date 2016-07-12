node(:status) { 'success' }
node(:total) { @total }
child(@schools => :data){
  attributes :id, :city_name, :name, :address, :contact_phone, :profile, :is_vip, :master,:logo, :found_at, :latitude, :longitude
}
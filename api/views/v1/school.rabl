node(:status) { 'success' }
child(@school => :data){
      attributes :id, :city_name, :name, :address, :contact_phone, :profile, :is_vip, :master,:logo, :found_at, :latitude, :longitude
      child(:products){
         attributes :id, :title, :description, :introduction, :show
      }
}
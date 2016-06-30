node(:status) { 'success' }
child(@school => :data){
      attributes :id, :city_name, :name, :address, :phone, :profile, :is_vip, :master,:logo, :found_at, :latitude, :longitude
      child(:product_bindings => :product){
         attributes :id, :title, :description, :introduction, :show
      }
}
node(:status) { 'success' }
child(@ad => :data){
  attributes :id, :title, :image, :value, :type, :url, :city_name
}
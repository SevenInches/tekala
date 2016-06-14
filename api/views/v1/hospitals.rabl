node(:status) { 'success' }
node(:total) { @total }
child(@hospitals => :data){
	attributes :id, :city_id, :name, :address, :latitude, :longitude, :note
}

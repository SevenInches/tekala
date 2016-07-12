node(:status) { 'success' }
child(@product => :data){
	attributes :id, :city_name, :name, :price, :description, :introduction, :can_buy, :exam_type, :created_at
	attributes :photos, :color, :show
}

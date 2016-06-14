node(:status) { 'success' }
child(@product => :data){
	attributes :id, :city, :name, :price_rmb, :exam_two_standard, :exam_three_standard, :total_quantity, :can_buy, :exam_type, :created_at
}

node(:status) { 'success' }
child(@product => :data){
	attributes :id, :name, :price, :exam_two_standard, :exam_three_standard, :total_quantity, :can_buy, :exam_type, :created_at
}

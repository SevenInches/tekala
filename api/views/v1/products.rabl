node(:status) { 'success' }
node(:total) { @total }
child(@products => :data){
  attributes :id, :city_name, :name, :price, :exam_two_standard, :exam_three_standard, :total_quantity, :can_buy, :exam_type, :created_at
}
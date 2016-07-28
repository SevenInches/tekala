node(:status) { 'success' }
node(:total) { @total }
child(@products => :data){
  attributes :id, :city_name, :name, :price, :description, :introduction, :can_buy, :created_at
  attributes :photos
  node(:color ) { |val| @demo.present? ? val.color_demo : val.color }
  node(:show ) { |val| @demo.present? ? val.show_demo : val.show }
  node(:exam_type ) { |val| @demo.present? ? val.exam_type_demo : val.exam_type }
}
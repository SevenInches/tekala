node(:status) { 'success' }
node(:total) { @total }
child(@products => :data){
  attributes :id, :city_name, :name, :price, :description, :introduction, :can_buy, :exam_type, :created_at
  attributes :photos, :color, :show
}
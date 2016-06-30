child(@product_binding => :data){
  attributes :id, :title, :description, :introduction, :c2_product_id, :c1_product_id, :c1_product, :photos, :city_name, :color, :show
child(:c1_product => :c1_product){
extends "v1/_product"
}

child(:c2_product => :c2_product){
extends "v1/_product"
}

}
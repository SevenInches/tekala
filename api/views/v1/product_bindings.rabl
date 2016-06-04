node(:status) { 'success' }
node(:total) { @total }
child(@product_bindings => :data){
	attributes :id, :title, :description, :introduction, :c2_product_id, :c1_product_id, :c1_product, :photos, :city, :color, :show
	child(:c1_product => :c1_product){
		extends "v3/_product"
	}

	child(:c2_product => :c2_product){
		extends "v3/_product"
	}

	
	
}
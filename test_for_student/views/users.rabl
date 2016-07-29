node(:status) { 'success' }
node(:total) { @total }
child(@users => :data){
	attributes :id, :name, :nickname, :mobile, :city_name, :sex, :score, :avatar_url, :avatar_thumb_url, :motto, :has_hour, :login_count, :has_assign, :address
	attributes :started_at,  :if => lambda { |val| !val.started_at.nil? }
	attributes :last_login,  :if => lambda { |val| !val.last_login.nil? }
	node(:status_flag ) { |val| @demo.present? ? val.status_flag_demo : val.status_flag}
	node(:exam_type ) { |val| @demo.present? ? val.exam_type_demo : val.exam_type}
	node(:type ) { |val| @demo.present? ? val.type_demo : val.type}
	child(:product) {
		node(:name ) { |product| @demo.present? ? '已报名班别' : product.name}
    }
}


node(:status) { 'success' }
child(@tweet => :data){
	attributes :id, :content, :city, :city_word, :user_id, :like_count, :comment_count, :photos, :created_at, :updated_at
	node(:has_like){ |val| val.has_like @user.id }
	child(:user) {
		attribute(:id, :name, :nickname, :mobile, :city_name, :sex, :age, :type, :type_word, :exam_type, :exam_type_word, :avatar_url, :status_flag_word, :status_flag)
		 
	}
}

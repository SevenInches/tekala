node(:status) { 'success' }
node(:total) { @total }
child(@tweets => :data){
	attributes :id, :content, :city, :city_word, :user_id, :comment_count, :like_count, :photos, :created_at, :updated_at
	node(:has_like){ |val| @user ? val.has_like(@user.id) : false  }
	child(:user){
		attribute(:id, :name, :nickname, :mobile, :city_name, :sex, :age, :type, :type_word, :exam_type, :exam_type_word, :avatar_url, :status_flag, :status_flag_word)
	}
}


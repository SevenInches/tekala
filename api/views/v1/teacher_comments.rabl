node(:status) { 'success' }
node(:total) { @total }
child(@comments => :data){
	attributes :id, :user_id, :teacher_id, :rate, :content, :created_at
	child(:user){
		attributes :id, :name, :nickname, :mobile, :city, :sex, :avatar_url, :avatar_thumb_url
	}
	child(:photos => :photos){
	    attributes :id, :photo_thumb_url, :photo_url

	}

}

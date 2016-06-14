node(:status) { 'success' }
child(@comment => :data){
	attributes :id, :user_id, :teacher_id, :rate, :content, :created_at
	
	child(:photos => :photos){
	    attributes :photo_thumb_url, :photo_url

	}

}

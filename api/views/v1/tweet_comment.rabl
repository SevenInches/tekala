node(:status) { 'success' }
child(@comment => :data){
	attributes :id, :user_id, :content, :created_at
	node(:is_reply ) { |val| val.reply_user_id.nil? ? false :  true  }
	
	child(:user) {
		attributes :id, :name, :nickname, :avatar_url
	}
	
	child(:reply_user => :reply_user){
		attributes :id, :name, :nickname, :avatar_url
	}

}
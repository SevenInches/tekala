node(:status) { 'success' }
child(@user => :data){
	attributes :id, :name, :nickname, :mobile, :city, :sex, :score, :school, :avatar_url, :avatar_thumb_url, :motto, :type, :type_word, :status_flag_word, :status_flag, :exam_type, :exam_type_word, :has_hour, :login_count, :has_assign
	node(:pass_first_exam) {  5531 }
	node(:pass_second_exam) { 2240 }
	node(:get_licence) { 491  }
	node(:id_card ) { |user| user.id_card.to_s.empty? ? '' :  user.id_card[0,12]+'******'  }
	attributes :birthday,    :if => lambda { |val| !val.birthday.nil? }
	attributes :started_at,  :if => lambda { |val| !val.started_at.nil? }
	attributes :last_login,  :if => lambda { |val| !val.last_login.nil? }
	node(:invite_text){ @invite_text }
	if @has_assign
	    child(:train_field => :train_field){
	    	attributes :id, :name, :longitude, :latitude, :address
	    }
	    child(:teacher){

			attributes :id, :id_card, :rate, :name, :profile, :wechat, :driving_age, :teaching_age, :avatar_thumb_url, :avatar_url, :status, :status_flag, :date_setting_filter, :mobile
			  attributes :remark,     :if => lambda { |val| !val.remark.nil? }
			  attributes :email,      :if => lambda { |val| !val.email.nil? }
			  attributes :age,    :if => lambda { |val| !val.age.nil? }
			  attributes :sex,    :if => lambda { |val| !val.sex.nil? }
			  attributes :qq,       :if => lambda { |val| !val.qq.nil? }
			  attributes :price,  :if => lambda { |val| !val.price.nil? }
			  attributes :promo_price,  :if => lambda { |val| !val.promo_price.nil? }
			  attributes :hometown,   :if => lambda { |val| !val.hometown.nil? }
			  attributes :skill,      :if => lambda { |val| !val.skill.nil? }
			  attributes :address,  :if => lambda { |val| !val.address.nil? }
			  node(:has_hour ) { |teacher| teacher.has_hour ? teacher.has_hour : 0  }
			  node(:comment_count ) { |teacher| teacher.comments ? teacher.comments.count : 0  }
			  child(@train_field => :train_fields){
			    	attributes :id, :name, :longitude, :latitude, :address
			  }	

		}
	end
}


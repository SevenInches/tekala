node(:status) { 'success' }
node(:total) { @total }
child(@teachers => :data){

	 attributes :id, :rate, :name, :profile, :driving_age, :teaching_age, :avatar_thumb_url, :avatar_url, :status, :status_flag, :exam_type, :tech_type, :exam_type_word, :date_setting_filter, :mobile, :subject, :subject_word
	  attributes :age,        :if => lambda { |val| !val.age.nil? }
	  attributes :sex,        :if => lambda { |val| !val.sex.nil? }
	  attributes :price,      :if => lambda { |val| !val.price.nil?  }
	  attributes :promo_price,  :if => lambda { |val| !val.promo_price.nil? }
	  attributes :hometown,   :if => lambda { |val| !val.hometown.nil? }
	  attributes :skill,      :if => lambda { |val| !val.skill.nil? }
	  attributes :address,  :if => lambda { |val| !val.address.nil? }
	  node(:has_hour ) { |teacher| teacher.has_hour ? teacher.has_hour : 0  }
	  node(:comment_count ) { |teacher| teacher.comment_size  }
	  child(:train_fields => :train_fields){
	  	attributes :id, :name, :address, :longitude, :latitude, :area, :teacher_count, :good_tags, :bad_tags, :area_word, :subject, :subject_word
	  }
	  
}

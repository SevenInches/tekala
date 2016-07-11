node(:status) { 'success' }
node(:total) { @total }
child(@train_fields => :data){
	attributes :id, :name, :address, :longitude, :latitude, :area_name, :good_tags, :bad_tags, :area_word, :subject, :subject_word
	attribute :distance,     :if => lambda { |val| !val.distance.nil? }
	attribute :teacher_num
	child(:school){
    	attributes :id, :city_name, :name, :address, :phone, :profile, :is_vip, :master,:logo, :found_at, :latitude, :longitude
    }
}

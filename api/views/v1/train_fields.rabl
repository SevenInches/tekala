node(:status) { 'success' }
node(:total) { @total }
child(@train_fields => :data){
	attributes :id, :name, :address, :longitude, :latitude, :area, :good_tags, :bad_tags, :area_word, :subject, :subject_word, :c1, :c2

	attribute :distance,     :if => lambda { |val| !val.distance.nil? }
	#该教练符合我学车车型的教练
	child(:school){
    	attributes :id, :city, :name, :address, :phone, :profile, :is_vip, :master,:logo, :found_at, :latitude, :longitude
    }
}

node(:status) { 'success' }
node(:total) { @total }
child(@fields => :data){
	attributes :id, :name, :address, :longitude, :latitude, :area_name, :good_tags, :bad_tags
	attribute :distance,     :if => lambda { |val| !val.distance.nil? }
	node(:subject ) { |val| @demo.present? ? val.subject_demo : val.subject }
}

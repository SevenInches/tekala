node(:status) { 'success' }
child(@products => :data){
	attributes :id, :name, :photo_url, :link

}

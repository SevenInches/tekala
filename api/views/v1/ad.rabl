node(:status) { 'success' }
child(@ad => :data){
  attributes :id, :cover_url, :route, :value, :type, :start_time, :end_time

}
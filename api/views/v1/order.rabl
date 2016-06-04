node(:status) { 'success' }
child(@order => :data){
  extends "v3/_order"
}


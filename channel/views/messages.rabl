node(:status) { 'success' }
node(:total) { @total }
child(@messages => :data) {
  attributes :id, :title, :click_num, :tag, :url, :date
}

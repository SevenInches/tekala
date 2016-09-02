node(:status) { 'success' }
node(:total) { @total }
child(@agency => :data) {
  attributes :id, :title, :content, :icon
  node(:url){@url}
}
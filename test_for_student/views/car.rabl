node(:status) { 'success' }
child(@car => :data){
  attributes :id, :produce_year, :note, :name
  node(:number ) { |val| @demo.present? ? '车牌号' : val.number}
  node(:identify ) { |val| @demo.present? ? '车架号' : val.identify}
  node(:brand ) { |val| @demo.present? ? '品牌' : val.brand}
}
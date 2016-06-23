node(:status) { 'success' }
node(:total) { @total }
child(@configs => :data){
  attributes :city, :name, :icon, :value, :type
}
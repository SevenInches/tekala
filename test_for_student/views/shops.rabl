node(:status) { 'success' }
node(:total) { @total }
child(@shops => :data){
  attributes :id, :name, :address, :contact_phone, :profile, :logo,  :config
  node(:student_count ) { |val| @demo.present? ? '招生人数' : val.student_count}
  node(:consultant_count ) { |val| @demo.present? ? '咨询人数' : val.consultant_count}
}
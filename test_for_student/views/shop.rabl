node(:status) { 'success' }
child(@shop => :data){
  attributes :id, :name, :address, :contact_phone, :contact_user, :profile, :logo,  :config, :longtitude, :latitude
  node(:rent_amount ) { |val| @demo.present? ? '租金' : val.rent_amount}
  node(:area ) { |val| @demo.present? ? '面积：X平方米' : val.area}
  node(:student_count ) { |val| @demo.present? ? '招生人数' : val.student_count}
  node(:consultant_count ) { |val| @demo.present? ? '咨询人数' : val.consultant_count}
}
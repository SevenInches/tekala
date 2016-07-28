node(:status) { 'success' }
child(@school => :data){
      attributes :id, :city_name, :name, :address, :contact_phone, :profile, :is_vip, :master, :logo, :found_at, :latitude, :longitude
      node(:user_num) { |val| @demo.present? ? '本月招生' : val.user_num }
      node(:signup_amount) { |val| @demo.present? ? '本月营收' : val.signup_amount  }
}
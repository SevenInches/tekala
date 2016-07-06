attributes :id, :order_no, :note, :subject, :price, :amount, :quantity, :promotion_amount, :discount, :type, 
:teacher_id, :user_id,  :status, :status_word, :created_at, :book_time, :has_coupon, :can_comment, :user_has_comment

attribute :pay_at,      :if => lambda { |val| !val.pay_at.nil? }
attribute :done_at,     :if => lambda { |val| !val.done_at.nil? }
attribute :cancel_at,   :if => lambda { |val| !val.cancel_at.nil? }
attribute :note,        :if => lambda { |val| !val.note.nil? }
child(:teacher) {
  attributes :id, :mobile, :name, :price, :avatar_url, :avatar_thumb_url, :rate, :has_hour, :date_setting_filter
  attribute :training_field,  :if => lambda { |val| !val.training_field.nil? }
}

child(:train_field => :train_field){
  attributes :id, :name, :area_word, :address, :longitude, :latitude, :good_tags, :bad_tags
}
child(:school){
  attributes :id, :city_name, :name, :address, :phone, :profile, :is_vip, :master,:logo, :found_at, :latitude, :longitude
}

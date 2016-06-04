node(:status) { 'success' }
child(@order => :data){
		attributes :id, :order_no, :note, :subject, :price, :amount, :quantity, :promotion_amount, :discount, :type, 
		:teacher_id, :user_id, 
		:device, :status,  :accept_status, :status_word, :created_at, :book_time, :has_coupon, :can_comment, :user_has_comment
		node(:book_time ) { |val| val.type == 1 ? '' : val.book_time }
		attribute :product_bind_id,  :if => lambda { |val| !val.product_bind_id.nil? }
		attribute :pay_at,      :if => lambda { |val| !val.pay_at.nil? }
		attribute :done_at,     :if => lambda { |val| !val.done_at.nil? }
		attribute :cancel_at,   :if => lambda { |val| !val.cancel_at.nil? }
		attribute :note,        :if => lambda { |val| !val.note.nil? }
}

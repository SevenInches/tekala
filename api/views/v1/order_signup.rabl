node(:status) { 'success' }
child(@order => :data){
		attributes :id, :order_no, :note, :subject, :price, :amount, :quantity, :promotion_amount, :discount, :type, 
		:teacher_id, :user_id, :school_id,  :status, :status_word, :created_at
		attribute :product_id,  :if => lambda { |val| !val.product_id.nil? }
		attribute :pay_at,      :if => lambda { |val| !val.pay_at.nil? }
		attribute :done_at,     :if => lambda { |val| !val.done_at.nil? }
		attribute :cancel_at,   :if => lambda { |val| !val.cancel_at.nil?}
}

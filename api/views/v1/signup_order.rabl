node(:status) { 'success' }
node(:msg) { @msg }

if @order
	child(@order){
	  attributes :id, :order_no, :note, :subject, :price, :amount, :promotion_amount, :discount, :teacher_id, :user_id, :device, :status, :created_at, :book_time, :type
	}
end
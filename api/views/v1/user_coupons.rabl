node(:status) { 'success' }
		
child(@user_coupons => :data){
	attributes :id, :user_id, :code, :status
	node(:coupon_id) { |m| m.coupon.id}
	node(:available) { |m| m.available}
	node(:available) { |m| m.available_word}
	node(:money) { |m| m.coupon.money}
	node(:start_at) { |m| m.coupon.start_at}
	node(:end_at) { |m| m.coupon.end_at}
	
}

	


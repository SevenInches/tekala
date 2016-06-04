class Sms 

  attr_accessor :teacher_name, :member_name, :teacher_mobile, :member_mobile, :book_time, :quantity, :order_no, :train_field_name, :money, :content 

  attr_accessor :teacher_mobile, :member_mobile, :teacher_word, :member_word
	def initialize(params)
		if params
			params.each do |key, value|
			  instance_variable_set("@#{key}", value)
			end
	 	end
    end

	def teacher_msm
		send("#{@teacher_name}教练您好，学员#{@member_name}(手机:#{@member_mobile})预约#{@book_time}在#{@train_field_name}训练场练车#{@quantity}小时。请提前10分钟到场，并在教学中保持耐心和友好。如有疑问，请立即联系我们4008456866", @teacher_mobile)
	end

	def member_msm 
		send("#{@member_name}同学，您已成功预约#{@teacher_name}教练(手机：#{@teacher_mobile})，#{@book_time}-#{@end_time}，在#{@train_field_name}训练场练车。请提前10分钟自行前往训练场，祝您学车愉快。", @member_mobile)
	end

	def refund 
		refund_content = "#{@member_name}学员，您的订单号为#{@order_no}，已成功退款。请留意微信支付帐号消息，订单金额#{@money}元将会在2-5个工作日内原路退回银行卡。"
		send(refund_content, @member_mobile)
		
		#填充数据
		if order = Order.first(:order_no => @order_no)
			SmsRecord.create(:content   => refund_content, 
	                         :to_user   => @member_name,
	                         :to_mobile => @member_mobile,
	                         :type      => 'refund',
	                         :order_id  => order.id)
		end
	end


	def send_sms
		# puts "======="
		# puts @teacher_word, @teacher_mobile, @member_word, @member_mobile
		# puts "======="
		teacher = send(@teacher_word, @teacher_mobile)
		member  = send(@member_word, @member_mobile)
		if teacher && member

			SmsRecord.create(:content   => @teacher_word, 
                       :to_mobile => @teacher_mobile,
                       :type      => 'book')
			SmsRecord.create(:content   => @member_word, 
                       :to_mobile => @member_mobile,
                       :type      => 'book')

			return 'success'
		else
			return 'failure'
		end

	end



	def validate 
		member = send(@content, @member_mobile)
		if  member

			SmsRecord.create(:content   => @content, 
                       :to_mobile => @member_mobile,
                       :type      => 'validate 短信验证码')

			return 'success'
		else
			return 'failure'
		end
	end

	def signup 
		member = send(@content, @member_mobile)
		if  member

			SmsRecord.create(:content   => @content, 
                       :to_mobile => @member_mobile,
                       :type      => 'signup 注册')

			return 'success'
		else
			return 'failure'
		end
	end

	def free_book
	    member = send(@content, @member_mobile)
		if  member

			SmsRecord.create(:content   => @content, 
                       :to_mobile => @member_mobile,
                       :type      => 'free_book 免费预约模拟器')

			return 'success'
		else
			return 'failure'
		end
		
	end

	def express 
		member = send(@content, @member_mobile)
		if member

			SmsRecord.create(:content   => @content, 
	                         :to_mobile => @member_mobile,
	                         :type      => 'express 快递协议')

			return 'success'
		else
			return 'failure'
		end
	end

	def order_confirm 
		teacher = send(@content, @teacher_mobile) 
		if teacher

			SmsRecord.create(:content   => @content, 
	                         :to_mobile => @teacher_mobile,
	                         :type      => 'order confirm 新订单提醒')

			return 'success'
		else
			return 'failure'
		end

	end

	def award_vaild 
		member = send(@content, @member_mobile)
		if member
			SmsRecord.create(:content   => @content, 
	                         :to_mobile => @member_mobile,
	                         :type      => 'award 年终奖活动验证手机')

			return 'success'
		else
			return 'failure'
		end
	end

	def signup_vaild 
		member = send(@content, @member_mobile)
		if member
			SmsRecord.create(:content   => @content, 
	                         :to_mobile => @member_mobile,
	                         :type      => 'signup 用户报名学车')

			return 'success'
		else
			return 'failure'
		end
	end

	def order_cancel_to_teacher 
		teacher = send(@content, @teacher_mobile) 
		if teacher
			SmsRecord.create(:content   => @content, 
	                         :to_mobile => @teacher_mobile,
	                         :type      => 'order_cancel_to_teacher 取消订单提醒')

			return 'success'
		else
			return 'failure'
		end

	end

	def order_cancel_to_member 
		teacher = send(@content, @member_mobile) 
		if teacher

			SmsRecord.create(:content   => @content, 
	                         :to_mobile => @member_mobile,
	                         :type      => 'order_cancel_to_member 新订单提醒')

			return 'success'
		else
			return 'failure'
		end
		
	end

	#团购
	def gogroup
		member = send(@content, @member_mobile)
		if  member
			SmsRecord.create(:content   => @content, 
	                         :to_mobile => @member_mobile,
	                         :type      => 'gogroup 双十二团购')
			return 'success'
		else
			return 'failure'
		end

	end

	#周结教练短信 发账单核对
	def week_or_daily_pay

		teacher = send(@content, @teacher_mobile) 
		if teacher
			SmsRecord.create(:content   => @content, 
	                         :to_mobile => @teacher_mobile,
	                         :type      => 'teacher_week_or_daily_pay 周结教练支付短信')

			return 'success'
		else
			return 'failure'
		end

	end

	def send(content,mobile)
		
		if Padrino.env != :development
			@curl =  Curl::Easy.new
		    @curl.url = CustomConfig::SMSADD
		    hash = {:username => CustomConfig::SMSNAME,
		            :password => Digest::MD5.hexdigest(CustomConfig::SMSNAME+Digest::MD5.hexdigest(CustomConfig::SMSPWD)),
		            :mobile   => mobile,
		            :content  => content,
		            :dstime   => '',
		            :msgfmt   => 'UTF-8'}
		    puts hash
		    @curl.http_post @curl.url, hash.map{ |k,v| Curl::PostField.content k, v }
		    # puts @curl.body_str
	    end
	    puts "===发送成功====="
	    return true

	end

end


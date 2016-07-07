# -*- encoding : utf-8 -*-
Szcgs::Api.controllers :v1, :orders do
	register WillPaginate::Sinatra
  enable :sessions
  current_url = '/api/v1'

  before :except => [:pay_done, :refund] do
    @user = User.get(session[:user_id])
    redirect_to("#{current_url}/unlogin") if @user.nil?
  end
  
  get :index, :provides => [:json] do 
    @orders = @user.orders.all(:order => :book_time.desc)
    #筛选类型
    tab = params[:tab]
    if tab
      case tab 
      when 'learning'
        @orders = @orders.all(:status => [1, 2, 4])
      when 'done'
        @orders = @orders.all(:status => 3)
      when 'cancel'
        @orders = @orders.all(:status => [5, 6, 7])
      end
    end
    
    @total  = @orders.count
    @orders = @orders.paginate(:per_page => 20, :page => params[:page])
    render 'v1/orders'
  end

  get :theme, :provides => [:json] do 
    if @user.status_flag < 7
      { :status => :success,
        :data => (Order::theme_api),
        :order => @user.status_flag,
      }.to_json
    else
      {:status => :success,
       :data => []
       }.to_json
    end
  end

  #客户端下订单前请求该接口看看是否需要付款 付款多少钱
  post :book_info, :provides => [:json] do 

    teacher = Teacher.get params[:teacher_id]
    return {:status => :failure, :msg => '未能找到该教练'}.to_json if teacher.nil?

    quantity          = params[:quantity].to_i
    total_hours       = @user.user_plan.exam_two_standard + @user.user_plan.exam_three_standard

    current_hours     = @user.user_plan.exam_two + @user.user_plan.exam_three


    #当前所学学时是否大于限制的总学时

    #pay_money = quantity* teacher.price if teacher.price.present?

    {:status => :success, :data => {:standard_hours => total_hours, :current_hours => current_hours, :quantity => quantity  } }.to_json
  end

  get :show_signup, :map => '/v1/orders/signup/:signup_id', :provides => [:json] do
    @order = Signup.get(params[:signup_id])
    render 'v1/order_signup'
  end

  get :show, :map => '/v1/orders/:order_id', :provides => [:json] do 
    @order = @user.orders.first(:id => params[:order_id])
    if @order
      render 'v1/order'
    else
      {:status => :failure, :msg => '未能找到该订单'}.to_json
    end
  end

  post :index, :provides => [:json] do 
    env            = request.env
    quantity       = params[:quantity].to_i

    @order                = Order.new
    @order.user_id        = @user.id
    @order.teacher_id     = params[:teacher_id]  ? params[:teacher_id] : 404
    if params[:train_field_id] && params[:train_field_id] != '0'
      @order.train_field_id     = params[:train_field_id]
    else
      last_order = Order.last(:teacher_id => @order.teacher_id, :user_id => @order.user_id, :status => Order::pay_or_done)
      @order.train_field_id     = last_order ? last_order.train_field_id : ''
    end
    @order.school_id        = @user.school_id
    @order.quantity       = quantity
    book_time             = "#{params[:book_date]} #{params[:book_time]}"
    @book_info            = @user.can_book_order(env, @order, book_time)
    @book_info.to_json
    if @book_info[:status] == :failure
      return @book_info.to_json
    end

    @order.subject    = params[:subject]
    @order.quantity   = quantity
    @order.price      = @order.teacher.price
    @order.exam_type  = @user.exam_type
    @order.note       = params[:note]
    @order.amount     = @order.price * @order.quantity if @order.price.present?
    @order.device     = params[:device]
    @order.longitude  = params[:longitude]
    @order.latitude   = params[:latitude]
    @order.city_id       = @user.city_id
    @order.subject    = "#{@order.quantity}小时学车费"
    @order.status     = 2
    @order.theme      = @user.status_flag > 6 ? 7 : params[:theme]
    @order.book_time  = book_time
    #
    if @order.save
      @order.generate_order_no
      @order.push_to_teacher #推送通知教练
    else
      {:status => :failure, :msg => @order.errors.full_messages.join(',')}.to_json
    end
    @order = Order.get @order.id
    render 'v1/order'

  end

  # 普通订单取消
  put :index, :map => '/v1/orders/:order_id', :provides => [:json] do 
    order = Order.first(:id => params[:order_id], :user_id => @user.id )
    if order && order.cancel
      return {:status => :success, :msg => '订单取消成功'}.to_json
    else
      return {:status => :failure, :msg => '取消订单不成功，请联系客服'}.to_json
    end
  end

  #app端支付 请求返回的charge内容
  post :signup_pay, :map => '/v1/signups/pay', :provides => [:json] do

    app_id  = CustomConfig::PINGAPPID #应用id

    channel = params[:channel].to_s.empty? ? 'wx' : params[:channel]

    @signup  = @user.signup

    return {:status => :failure, :msg => '没有该订单'}.to_json if @signup.nil?

    subject = @signup.product.name

    return {:status => :failure, :msg => '未选择支付金额'}.to_json if @signup.amount == 0.0

    CustomConfig.pingxx

    order_result = Pingpp::Charge.create(
        :order_no  => @signup.order_no,
        :amount    => @signup.amount*100,
        :subject   => subject,
        :body      => subject,
        :channel   => channel,
        :currency  => "cny",
        :client_ip => request.ip,
        :app       => { :id => app_id },
        :extra     => {}
    )

    result = JSON.parse(order_result.to_s)

    @signup.ch_id = result['id'].to_s
    @signup.pay_channel = result['channel'].to_s
    if @signup.save!
      return {:status => :success,
              :data => {
                  :result     => order_result.to_s,
                  :is_live    => result['livemode'],
                  :channel    => result['channel'],
                  :pay_status => @signup.status
              }
      }.to_json
    else
      return {:status => :error, :msg => '报名订单状态未改变'}.to_json
    end
  end

  #app端支付 请求返回的charge内容
  post :pay, :map => '/v1/orders/:order_id/pay', :provides => [:json] do  

    app_id  = CustomConfig::PINGAPPID #应用id

    channel = params[:channel].to_s.empty? ? 'wx' : params[:channel]

    @order  = @user.orders.first(:id => params[:order_id], :status.lt => 102)

    return {:status => :failure, :msg => '没有该订单'}.to_json if @order.nil?

    amount  = @order.promotion_amount > 0 ? (@order.promotion_amount * 100).to_i : 1 #如果优惠价格0的话 默认支付0.01元，供测试使用

    subject = @order.subject

    return {:status => :failure, :msg => '未选择支付金额'}.to_json if @order.price == 0
    
    CustomConfig.pingxx
     
      order_result = Pingpp::Charge.create(
          :order_no  => @order.order_no,
          :amount    => amount,
          :subject   => subject,
          :body      => subject,
          :channel   => channel,
          :currency  => "cny",
          :client_ip => request.ip,
          :app       => { :id => app_id },
          :extra     => {}
      )

      result = JSON.parse(order_result.to_s)
      @order.ch_id = result['id']
      @order.pay_channel = channel
      @order.save
      return {:status => :success,
              :data => {
              :result     => order_result.to_s,
              :is_live    => result['livemode'],
              :channel    => result['channel'],
              :pay_status => @order.status
             }
            }.to_json
  end


  #购买产品订单
  post :index_signups, :map => '/v1/orders/signups', :provides => [:json] do
    product = Product.get(params[:product_id])
    if product.can_buy
      if @user.signup.present?
        @user.signup.destroy
      end
      @order = @user.create_signup(product)
      if @order.nil?
      {:status => :failure, :msg => '产品订单生成失败，请联系小萌' }.to_json
      else
        # 用户城市修改
        @user.city_id = @order.city_id
        @user.save
        render 'v1/order_signup'
      end
    else
      {:status => :failure, :msg => '该产品暂不能购买' }.to_json
    end
  end

  # ping++ 请求 template
  #
  # "{\"id\":\"evt_Y1o7j5OQFEJQlS5eClV62qP6\",
  # \"created\":1435302444,
  # \"livemode\":false,\"type\":\"charge.succeeded\",
  # \"data\":{\"object\":{\"id\":\"ch_jTyzP4qrnj18WrXbnHePGiPC\",\"object\":\"charge\",\"created\":1435302441,\"livemode\":false,\"paid\":true,\"refunded\":false,\"app\":\"app_jz580OWvPGaTXTKK\",\"channel\":\"wx\",\"order_no\":\"20150626150718662273\",\"client_ip\":\"183.17.253.246\",\"amount\":11900,\"amount_settle\":0,\"currency\":\"cny\",\"subject\":\"empty\",\"body\":\"empty\",\"extra\":{},\"time_paid\":1435302444,\"time_expire\":1435388841,\"time_settle\":null,\"transaction_no\":\"1273950615201506262524717344\",\"refunds\":{\"object\":\"list\",\"url\":\"/v1/charges/ch_jTyzP4qrnj18WrXbnHePGiPC/refunds\",\"has_more\":false,\"data\":[]},\"amount_refunded\":0,\"failure_code\":null,\"failure_msg\":null,\"metadata\":{},\"credential\":{},\"description\":null}},\"object\":\"event\",\"pending_webhooks\":0,\"request\":\"iar_nX5OePvHKyvH1CKGG844mDiD\"}"
  post :pay_done, :map => '/v1/signups/pay_done', :provides => [:json] do
    notify = request.body.read
    ping_result = JSON.parse(notify.to_s)
    #付款成功
    if ping_result['data']['object']['id'] && ping_result['type'] == 'charge.succeeded'
      @signup = Signup.first(:ch_id => ping_result['data']['object']['id'])
      if @signup
        @user = @signup.user
        @user.product_id = @signup.product_id
        @user.status_flag = 1
        @user.save

        #付款时间
        @signup.pay_at = Time.now
        @signup.status = 2
        @signup.save!

        #付款成功 发短信通知用户

        sms = Sms.new(:content        => "#{@user.name}学员，您已报名#{@signup.school.name}，并支付成功。如有疑问，请通过微信公众号进行咨询。祝您学车愉快。",
                      :member_mobile  => "#{@user.mobile}")
        sms.signup

      end
    end #order
  end #post :pay_done


  ############
  #
  ## ping++ hook 报名 回调 退款
  ## REFUND && PAY_DONE
  #
  #############

  post :refund, :map => '/v1/signups/refund',:provides => [:json] do
    notify = request.body.read
    ping_result = JSON.parse(notify.to_s)
    #退款功能  退款成功
    if ping_result['data']['object']['id'] && ping_result['type'] == 'refund.succeeded'
      @signup = Signup.first(:ch_id => ping_result['data']['object']['charge'])

      if @signup
        @user = @order.user
        @user.status_flag = 0
        @user.save

        @signup.cancel_at = Time.now
        @signup.status = 6
        @signup.save!
      end
    end
  end

end
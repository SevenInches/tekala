# -*- encoding : utf-8 -*-
Szcgs::Api.controllers :v1, :orders do  
	register WillPaginate::Sinatra
  enable :sessions
  current_url = '/api/v1'

  before do 
    @user = User.get(session[:user_id])
    redirect_to("#{current_url}/unlogin") if @user.nil?
  end
  
  get :index, :provides => [:json] do 
    @orders = @user.orders.all(:type => Order::NORMALTYPE, :order => :book_time.desc)
    #筛选类型
    tab = params[:tab]
    if tab
      case tab 
      when 'learning'
        @orders = @orders.all(:status => [101, 102, 104])
      when 'done'
        @orders = @orders.all(:status => 103)
      when 'cancel'
        @orders = @orders.all(:status => [0, 1, 2])
      end
    end
    
    @total  = @orders.count
    @orders = @orders.paginate(:per_page => 20, :page => params[:page])
    render 'v1/orders'
  end

  get :index_signup, :map => '/v1/orders/signup', :provides => [:json] do
    @orders = @user.signups.all
    @total  = @orders.count
    render 'v1/order_signups'
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
    product           = @user.product
    total_hours       = @user.user_plan.exam_two_standard + @user.user_plan.exam_three_standard

    current_hours     = @user.user_plan.exam_two + @user.user_plan.exam_three

    #是否限制学时 0 不限制 其他则限制该学时
    product_quantity  =  product.pay_type.quantity
    user_limit        =  (product_quantity != 0) ? true : false

    #当前所学学时是否大于限制的总学时
    if current_hours > total_hours || @user.type == 0
      pay_money = quantity*teacher.price
    else
      pay_hours = (quantity - (total_hours - current_hours)) 
      hours     = (pay_hours > 0 && user_limit) ? pay_hours : 0
      pay_money = hours* teacher.price
    end
    {:status => :success, :data => {:user_limit => user_limit, :standard_hours => total_hours, :current_hours => current_hours, :pay_money => pay_money  } }.to_json
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
    product        = @user.product
    total_hours    = product.exam_two_standard + product.exam_three_standard
    current_hours  = @user.user_plan.exam_two + @user.user_plan.exam_three + quantity

    @order                = Order.new
    @order.teacher_id     = params[:teacher_id]  ? params[:teacher_id] : 404
    @order.quantity       = params[:quantity]
    book_time             = "#{params[:book_date]} #{params[:book_time]}"
    @order.train_field_id = params[:train_field_id]
    @book_info            = @user.can_book_order(env, @order, book_time)

    if @book_info[:status] == :failure
      return @book_info.to_json
    end

    @order.user_id    = @user.id
    @order.subject    = params[:subject]
    @order.quantity   = params[:quantity]
    @order.price      = @order.teacher.price
    #如果用户是C2类型的
    @order.price      = @order.teacher.price + 20 if @user.exam_type == 2 
    @order.exam_type  = @user.exam_type
    @order.note       = params[:note]
    @order.amount     = @order.price * @order.quantity
    @order.device     = params[:device]
    @order.longitude  = params[:longitude]
    @order.latitude   = params[:latitude]
    @order.city       = @user.city
    @order.subject    = "萌萌学车#{@order.quantity}小时学车费"
    if params[:train_field_id] && params[:train_field_id] != '0'
      @order.train_field_id     = params[:train_field_id] 
    else
      last_order = Order.last(:teacher_id => @order.teacher_id, :user_id => @order.user_id, :status => Order::pay_or_done)
      @order.train_field_id     = last_order ? last_order.train_field_id : ''
    end
    @order.status     = 101
    @order.theme      = @user.status_flag > 6 ? 7 : params[:theme]
    @order.book_time  = book_time

    #判断是否打包教练的学员下单
    if @user.has_assign
      @order.type = Order::FREETOTEACHER #type=2是打包的订单类型
    end
    if @order.save
      @order.generate_order_no
      #最开始版本小时班有学时优惠券 以后可以去除
      #/*使用优惠券
      if params[:coupon_code]
        coupon = UserCoupon.first(:code => params[:coupon_code], :user_id => @user.id)
        if coupon && coupon.available == 200
          coupon.order_id = @order.id
          coupon.status   = 0
          coupon.save
        end
      end
      #使用优惠券 */
      if @user.type == 1 #会员用户 折扣=总价 直接把状态改为已经支付
        @order.discount = @order.amount
        @order.status   = 102
        @order.save
      end
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
  post :signup_pay, :map => '/v1/signups/:signup_id/pay', :provides => [:json] do

    app_id  = CustomConfig::PINGAPPID #应用id

    channel = params[:channel].to_s.empty? ? 'wx' : params[:channel]

    @signup  = @user.signups.first(:id => params[:signup_id], :status => 0)

    return {:status => :failure, :msg => '没有该订单'}.to_json if @signup.nil?

    subject = @signup.product.name

    return {:status => :failure, :msg => '未选择支付金额'}.to_json if @signup.amount == 0.0

    CustomConfig.pingxx

    order_result = Pingpp::Charge.create(
        :order_no  => @signup.order_no,
        :amount    => @signup.amount,
        :subject   => subject,
        :body      => subject,
        :channel   => channel,
        :currency  => "cny",
        :client_ip => request.ip,
        :app       => { :id => app_id },
        :extra     => {}
    )

    result = JSON.parse(order_result.to_s)
    @signup.ch_id = result['id']
    @signup.pay_channel = channel
    @signup.save
    return {:status => :success,
            :data => {
                :result     => order_result.to_s,
                :is_live    => result['livemode'],
                :channel    => result['channel'],
                :pay_status => @signup.status
            }
    }.to_json
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
end
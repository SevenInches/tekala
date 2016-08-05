# -*- encoding : utf-8 -*-
Tekala::App.controllers :m do
  register WillPaginate::Sinatra
  enable :sessions

  before :except => [:login, :signup, :index, :products, :detail] do
    if session[:user_id].present?
      @user = User.get(session[:user_id])
      redirect_to(url(:m, :login, :back => request.url)) if @user.nil?
    else
      redirect_to(url(:m, :login, :back => request.url))
    end

  end

  #如果已经支付 得先完善资料
  before :except => [:login, :signup, :edit_profile, :index, :products, :detail] do
    if @user.email.blank?  || @user.name.blank? || @user.id_card.blank? || @user.address.blank?
      redirect_to(url(:m, :edit_profile))
    end
  end

  get :login do
    @tab_nav = 'hidden'
    @title   = '登录'
    @logout  = false
    session[:user_id] = nil
    render 'm/login', :layout => 'layouts/m_application'
  end

  post :login do
    @logout  = false
    @tab_nav = 'hidden'
    @user = User.authenticate_by_mobile(params[:mobile], params[:password])
    if @user
      session[:user_id] = @user.id
      if !params[:back].blank?
        redirect_to(params[:back])
      else
        redirect_to(url(:m, :index))
      end
    else
      @error_msg = '用户名/密码错误'
      render 'm/login', :layout => 'layouts/m_application'
    end
  end

  get :signup do
    @title   = '注册'
    @tab_nav = 'hidden'
    @logout  = false
    render 'm/signup', :layout => 'layouts/m_application'
  end

  post :signup do
    @logout  = false
    @tab_nav = 'hidden'
    user = User.first(:mobile => params[:mobile])
    if user
      @error_msg = '该手机号已注册，请直接登录'
      render 'm/signup', :layout => 'layouts/m_application'
    else
      @user = User.new
      @user.name = params[:name]
      @user.nickname = params[:nickname]
      @user.mobile   = params[:mobile]
      @user.password = params[:password]
      @user.save

      #统计 发请求
      # begin
      #   uri = URI("http://www.yommxc.com/updata?identify=#{cookies[:identify]}&event=0")
      #   Net::HTTP.get(uri)
      # rescue
    end

    response.set_cookie('user_id', :value => @user.id, :path => '/', :expires => Time.now + 3600*24*7*150)
    if !params[:back].blank?
      redirect_to(params[:back])
    else
      redirect_to(url(:m, :index))
    end
  end

  get :edit_profile, :map => '/m/edit_profile' do
    @title   = '完善资料'
    @tab_nav = 'hidden'
    render 'm/edit_profile', :layout => 'layouts/m_application'
  end

  get :products, :map => '/m/:id/products' do
    @title    = '班别列表'
    @tab_nav  = 'hidden'
    @logout   = false
    @back     = params[:back].present? ? params[:back] : url(:m, :products)
    school    = School.get(params[:id])
    if school.present?
      @products = school.products.all(:show => true)
      render 'm/products', :layout => 'layouts/m_application'
    else
      redirect_to(url(:m, :index))
    end
  end

  get :detail, :map => '/m/product/:id' do
    @title   = '班别详情'
    @tab_nav = 'hidden'
    @logout  = false
    @product = Product.get(params[:id])
    @back    = params[:back].present? ? params[:back] : url(:m, :products)
    @user    = User.get(session[:user_id]) if session[:user_id].present?
    render 'm/detail', :layout => 'layouts/m_application'
  end

  post :buy do
    @product = Product.get(params[:product_id])
    @order = Signup.first(:product_id => @product.id, :user_id => @user.id, :status => 1)
    if @order.nil?
      @user.product_id = @product.id
      @order = @user.create_signup(@product)
      @user.city_id = @order.city_id
      @user.save
      #统计 产生订单
      # begin
      #   uri = URI("http://www.yommxc.com/updata?identify=#{cookies[:identify]}&event=1")
      #   Net::HTTP.get(uri)
      # rescue
      # end
    end
    redirect_to(url(:m, :orders))
  end

  get :weixin_login do
    @appid   = CustomConfig::PAY_APPID
    @secret  = CustomConfig::PAY_SECRET
    @url     = params[:url]
    redirect("https://open.weixin.qq.com/connect/oauth2/authorize?appid=#{@appid}&redirect_uri=#{@url}&response_type=code&scope=snsapi_userinfo&state=STATE&connect_redirect=1#wechat_redirect")
  end

  get :mine do
    @tab_nav   = 'hidden'
    @title     = '个人详情'
    @logout    = false
    @back    = params[:back].present? ? params[:back] : url(:member, :index)
    key        = "20150607mm"
    @token     = Digest::MD5.hexdigest("#{@user.id}#{key}")
    @has_learn = (up = @user.user_plan) ? up.exam_two + up.exam_three  : 0
    render 'member/mine', :layout => 'layouts/member_application'
  end

  post :edit_profile do
    if @user.update(params)
      redirect_to(url(:m, :index, session[:school_id]))
    else
      redirect_to(url(:m, :edit_profile))
    end
  end

  get :orders do
    #微信登陆
    @appid           = CustomConfig::PAY_APPID
    @secret          = CustomConfig::PAY_SECRET

    user_info        = ''
    @wechat_unionid  = ''
    @city_list       = 'hidden'

    if Padrino.env == :production && ( session[:wechat_unionid].nil? || session[:wechat_unionid].empty? )

      redirect(url(:m, :weixin_login, :url => ERB::Util.url_encode(request.url))) if params[:code].blank?

      uri = "https://api.weixin.qq.com/sns/oauth2/access_token?appid=#{@appid}&secret=#{@secret}&code=#{params[:code]}&grant_type=authorization_code"
      html_response   = ''
      open(uri) do |http|
        html_response = http.read
      end

      #如果拿不到数据则返回 登陆微信code
      if html_response == ''
        redirect(url(:m, :weixin_login, :url => ERB::Util.url_encode(request.url)))
      else
        json = JSON.parse html_response
        userInfoUrl = "https://api.weixin.qq.com/sns/userinfo?access_token=#{json['access_token'].to_s}&openid=#{json['openid'].to_s}&lang=zh_CN"
        open(userInfoUrl) do |http|
          user_info = http.read
        end
      end

      @wechat_user    = JSON.parse(user_info)

      @wechat_unionid = @wechat_user["openid"].to_s
      @wechat_avatar  = @wechat_user["headimgurl"].to_s
      @wechat_name    = @wechat_user["nickname"].to_s
      @open_id        = @wechat_user["openid"].to_s

      session[:wechat_avatar]  = @wechat_avatar
      session[:wechat_unionid] = @wechat_unionid
      session[:wechat_name]    = @wechat_name
      session[:open_id]        = @open_id

    else
      @wechat_avatar   = session[:wechat_avatar]
      @wechat_unionid  = session[:wechat_unionid]
      @wechat_name     = session[:wechat_name]
      @open_id         = session[:open_id]
    end

    @title    = '购买记录'
    @page     = "orders"

    @orders   = Signup.all(:user_id => @user.id, :order => :id.desc)
    render 'm/orders', :layout => 'layouts/m_application'
  end

  post :pay_web, :provides => [:json] do

    api_key = (params[:is_live] == '1' && Padrino.env == :production ) ? CustomConfig::PINGLIVE : CustomConfig::PINGTEST

    app_id  = CustomConfig::PINGAPPID #应用id

    @order  = Signup.first(:order_no => params[:order_no], :user_id => params[:user_id], :status=>1)

    return {:status => :failure, :msg => '没有该订单'}.to_json if @order.nil?

    amount  = @order.amount * 100


    return {:status => :failure, :msg => '未选择支付金额'}.to_json if @order == 0

    begin

      CustomConfig.pingxx
      order_result = Pingpp::Charge.create(
          :order_no  => @order.order_no,
          :amount    => amount,
          :subject   => @order.product.name+'报名费',
          :body      => @order.product.name+'报名费',
          :channel   => "wx_pub",
          :currency  => "cny",
          :client_ip => request.ip,
          :app       => { :id => app_id },
          :extra     => { :open_id => params[:open_id]}
      )

      result = JSON.parse(order_result.to_s)
      @order.ch_id = result['id']
      @order.pay_channel = 'wx_pub'
      @order.save

      return order_result.to_json

    rescue => err
      puts err
    ensure
    end
  end

  get :index, :map => '/m/:id' do
    if params[:id].present? && params[:id].to_i>0
      @school = School.get(params[:id])
      if @school.present?
        session[:school_id] = @school.id
      end
      @title    = '特快拉 -- '+@school.name
      render 'm/index', :layout => 'layouts/m_application'
    else
      halt 404
    end
  end

end
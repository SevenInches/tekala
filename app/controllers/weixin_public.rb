# -*- encoding : utf-8 -*-
Tekala::App.controllers :weixin_public do
  register WillPaginate::Sinatra
  enable :sessions

  # set :delivery_method, :smtp => { 
  #   :address              => CustomConfig::EMAILSMTP,
  #   :port                 => CustomConfig::EMAILPORT,
  #   :user_name            => CustomConfig::EMAILADD,
  #   :password             => CustomConfig::EMAILPWD,
  #   :authentication       => :plain,
  #   :enable_starttls_auto => true  
  # }

  before :except => [:weixin_login, :signup, :midautumn, :index, :success, :mid_success, :train_field_list, :article, :pay_page, :pay] do
      
    session[:user_id] = cookies[:user_id] if cookies[:user_id] && !cookies[:user_id].empty?
    
    if session[:user_id]
        @user    = User.get session[:user_id]
        @back_url = URI::encode(request.url)
    end
  end


  #自主注册 weixin登陆
  get :weixin_login do 
      @appid   = CustomConfig::APPID
      @secret  = CustomConfig::SECRET

      @url   = (params[:url] && !params[:url].empty?) ? params[:url] : "http%3a%2f%2fwww.mmxueche.com%2fm%2fweixin_public%2fsignup"
      redirect("https://open.weixin.qq.com/connect/oauth2/authorize?appid=#{@appid}&redirect_uri=#{@url}&response_type=code&scope=snsapi_userinfo&state=STATE&connect_redirect=1#wechat_redirect")
  end



  get :index do 
    session[:user_id] = cookies[:user_id] if cookies[:user_id] && !cookies[:user_id].empty?
    @user  = User.get session[:user_id]
    if @user && @user.type == 1
      redirect_to(url(:login))  
    elsif @user
      redirect_to(url(:weixin_public, :confirm))
    end
  	render 'weixin_public/index', :layout => false
  end



  get :signup do 
      @appid   = CustomConfig::APPID
      @secret  = CustomConfig::SECRET
      redirect(url(:weixin_public, :weixin_login)) if params[:code].nil? || params[:code].empty?
      uri = "https://api.weixin.qq.com/sns/oauth2/access_token?appid=#{@appid}&secret=#{@secret}&code=#{params[:code]}&grant_type=authorization_code"
      html_response   = ''
      user_info       = ''
      open(uri) do |http|  
        html_response = http.read  
      end
      #如果拿不到数据则返回 登陆微信code
      if html_response == ''
          redirect(url(:weixin_public, :weixin_login))
      else
          json = JSON.parse html_response
          userInfoUrl = "https://api.weixin.qq.com/sns/userinfo?access_token=#{json['access_token'].to_s}&openid=#{json['openid'].to_s}&lang=zh_CN"
          open(userInfoUrl) do |http|  
            user_info = http.read  
          end
      end

      @wechat_user = JSON.parse(user_info)  
      
      params[:wechat_avatar]  = @wechat_user["headimgurl"].to_s
      params[:wechat_unionid] = @wechat_user["openid"].to_s

  	  render 'weixin_public/signup', :layout => false
  end

  

  post :signup do 
    @user = User.first_or_create(:mobile => params[:mobile])

    @user.name      = params[:name]
    @user.nickname  = params[:name]
    @user.email     = params[:email]
    @user.id_card   = params['id-card']
    @user.local     = params['local']
    @user.live_area = params['live_area']
    @user.work_area = params['work_area']
    @user.password  = params['password']
    @user.wechat_avatar  = params['wechat_avatar']
    @user.wechat_unionid = params['wechat_unionid']
    @user.beta      = 1
    @user.rank      = 0 
    @user.city      = "0755"
    @user.section   = 7 if @user.section.nil?

    if @user.save
      @user = User.authenticate_by_mobile(@user.mobile, @user.password)

      # if @user.id_card.to_s[6,4].to_i < 1984
      #   redirect(url(:weixin_public, :confirm))
      # end

      if @user
            
            session[:user_id] =  @user.id
            response.set_cookie('user_id', :value => @user.id, :path => '/', :expires => Time.now + 3600*24*7*150)
           
            redirect(url(:weixin_public, :confirm))
      end

    else
      @error = @user.errors.full_messages.first
      render 'weixin_public/signup', :layout => false
    end
  end

  get :faq do 
    @header   = 'hidden'
    @tab_nav  = 'hidden'
    render 'weixin_public/faq'
  end

  get :success do 
    @header   = 'hidden'
    @tab_nav  = 'hidden'
    render 'weixin_public/success'
  end

  get :confirm do 
      # if @user && @user_guide = @user.user_guide 
      #   redirect_to(url("/guide/take_photo")) if @user_guide.pay 
      # end
      # 200元预付款
      
      @order = Order.first(:user_id => @user.id, :type => Order::VIPTYPE, :status => 101)
      if @order.nil?
        @order = Order.new
        @order.order_no   = Order::generate_order_no_h5 
        @order.quantity   = 1
        @order.type       = Order::VIPTYPE
        
        @order.teacher_id = 477
        @order.user_id    = @user.id

        @order.price      = 4800

        @order.subject    = '4800元包过班'
        @order.note       = '包过班 4800元'
        @order.amount     = @order.price * @order.quantity
        @order.device     = '微信H5支付-公众账号自主注册'
        @order.book_time  = Date.today

        @order.save
      end

      @tab_nav = 'hidden'
      @header  = 'hidden'

      @nav_word = '确认订单'
      render 'weixin_public/confirm'
  end


  get :wechat_login do 

      @order = Order.first(:id => params[:order_id], :user_id => @user.id)
      
      redirect_to(url(:login)) if @order.nil? || @order.status != 101

      @appid  = CustomConfig::APPID
      @secret = CustomConfig::SECRET
      # @number  = (params[:number].nil? || params[:number].empty?) ? 1 : params[:number]
      @url   = "http%3a%2f%2fwww.mmxueche.com%2fm%2fweixin_public%2fpay_page%3forder_id%3d#{@order.id}"
      redirect("https://open.weixin.qq.com/connect/oauth2/authorize?appid=#{@appid}&redirect_uri=#{@url}&response_type=code&scope=snsapi_userinfo&state=STATE&connect_redirect=1#wechat_redirect")
  end


  get :pay_page do 
      @order = Order.first(:id => params[:order_id], :user_id => @user.id)

      redirect_to(url(:weixin_public, :success)) if @order.nil? || @order.status != 101

      @appid  = CustomConfig::APPID
      @secret = CustomConfig::SECRET

      uri = "https://api.weixin.qq.com/sns/oauth2/access_token?appid=#{@appid}&secret=#{@secret}&code=#{params[:code]}&grant_type=authorization_code"
      html_response   = ''
      user_info       = ''

      open(uri) do |http|  
        html_response = http.read  
      end

      #如果拿不到数据则返回 登陆微信code
      if html_response == ''
          redirect(url(:weixin_public, :wechat_login, :order_id => @order.id))
      else
          json = JSON.parse html_response
          userInfoUrl = "https://api.weixin.qq.com/sns/userinfo?access_token=#{json['access_token'].to_s}&openid=#{json['openid'].to_s}&lang=zh_CN"
          open(userInfoUrl) do |http|  
            user_info = http.read  
          end
      end

      @wechat_user = JSON.parse(user_info) 

      @open_id     = @wechat_user["openid"].to_s
      @order_no    = @order.order_no
      @user_id     = @order.user_id
      @order_id    = @order.id
      
      render 'weixin_public/pay_page', :layout => false
  end


  get :pay do 
      #module支付失败跳转到指定模块的 pay_page
      @module = params[:module].to_s.empty? ? '/m/weixin_public/pay_page' : "/m/#{params[:module]}/pay_page" 

      @order  = Order.first(:id => params[:order_id], :status => 101)
      redirect_to(url(:weixin_pay, :success)) if @order.nil?
      
      @appid  = CustomConfig::APPID
      @secret = CustomConfig::SECRET

      uri = "https://api.weixin.qq.com/sns/oauth2/access_token?appid=#{@appid}&secret=#{@secret}&code=#{params[:code]}&grant_type=authorization_code"
      html_response   = ''
      user_info       = ''

      open(uri) do |http|  
        html_response = http.read  
      end

      #如果拿不到数据则返回 登陆微信code
      if html_response == ''
          redirect(url(:weixin_pay, :login, :order_id => @order.id))
      else
          json = JSON.parse html_response
          userInfoUrl = "https://api.weixin.qq.com/sns/userinfo?access_token=#{json['access_token'].to_s}&openid=#{json['openid'].to_s}&lang=zh_CN"
          open(userInfoUrl) do |http|  
            user_info = http.read  
          end
      end

      @wechat_user = JSON.parse(user_info) 

      @open_id     = @wechat_user["openid"].to_s
      @order_no    = @order.order_no
      @user_id     = @order.user_id
      @order_id    = @order.id
      
      render 'weixin_pay/pay_page', :layout => false
   end

  get :train_field_list do 
        @tab_nav  = 'hidden'
        @train_fields   = TrainField.all(:count.gt => 0, :display => true)

        if params[:type] == 'position' && params[:longitude] && params[:longitude]
            adapter = DataMapper.repository(:default).adapter 
            @train_fields = repository(:default).adapter.select("SELECT 6371 * acos(cos(radians(#{params[:latitude]})) * cos(radians(latitude)) * cos(radians(longitude) - radians(#{params[:longitude]})) + sin(radians(#{params[:latitude]})) * sin(radians(latitude))) as distance, count as teacher_count, id, name, latitude, longitude, address, area from train_fields where display = 1 and count > 0 HAVING distance<=100 order by distance limit 50")
        end

        render 'weixin_public/train_field'
    end


  get :article, :with=> :article_id do 
     @article = Article.get params[:article_id]
     render 'weixin_public/article_preview', :layout => false
  end

end

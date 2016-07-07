# -*- encoding : utf-8 -*-
Szcgs::Api.controllers :v1 do  
	register WillPaginate::Sinatra
  	enable :sessions
    current_url = '/api/v1'
    before :except => [:login, :logout, :unlogin, :signup, :hospitals, :history, :city_list, :questions, :exam_info] do 
      @user = User.get(session[:user_id])
      redirect_to("#{current_url}/unlogin") if @user.nil?
    end

    #####
    #
    #desc 用户登陆退出 etc.
    #
    #####
  	post :login, :provides => [:json] do 
  		@user = User.authenticate_by_mobile(params[:mobile], params[:password])
  		if @user 

  			@user.device  		 = params[:device]
  			@user.version 		 = params[:version]
  			@user.longitude    = params[:longitude] if params[:longitude]
        @user.latitude     = params[:latitude]  if params[:longitude]
        @user.login_count ||= 0
        @user.login_count  += 1
        @user.save

        session[:user_id] = @user.id
        if @has_assign = @user.has_assign
        	@train_field = @user.train_field
        end
        
        @school = @user.school

        @invite_text = "使用我的邀请码 #{@user.invite_code}，获得萌萌学车 50 元学车优惠，深圳考驾照只需 5630。点击链接立即报名：http://www.mmxueche.com/invite/#{@user.invite_code}"
  			render 'v1/user'
  		else
  			msg = User.first(:mobile => params[:mobile]) ? '密码错误' : '用户名错误'
  			{:status => :failure, :msg => msg}.to_json
  		end
  	end

    get :logout, :provides => [:json] do
      session[:user_id] = nil
      {:status => :success, :msg => '成功退出登陆'}.to_json
    end

  	get :unlogin, :provides => [:json] do
  		{:status => :failure, :msg => '未登录'}.to_json	
  	end

    ########
    #
    #desc 用户注册 etc.
    #
    ########
    post :signup, :provides => [:json] do 
      @user = User.first(:mobile => params[:mobile])
      if !empty?(params[:mobile]) && @user.nil? 

        #验证码是否过期
        validate = UserValidate.first(:mobile => params[:mobile])
        if !(validate && (validate.updated_at + 10.minute > Time.now)  && (validate.code == params[:validate_code]))
          return {:status => :failure, :msg => '验证码错误'}.to_json
        end

        @user = User.new
        @user.mobile   = params[:mobile]
        @user.name     = params[:name]
        @user.nickname = params[:nickname]
        @user.password = params[:password]
        @user.email    = params[:email]
        @user.city_id  = params[:city_id]
        @user.school_id= params[:school_id]
        @user.avatar   = params[:avatar]

        if params[:city_id].present?
          @user.city_id = params[:city_id]
        end

        #如果有给用户指定产品
        product = Product.get(params[:product_id])
        if product && product.can_buy #产品存在并可购买
          @user.product_id = product.id
          if params[:city_id].nil?
            @user.city_id = product.city_id
          end
        end
        
        @user.status_flag  = 0
        @user.save
        @user.send_sms(:signup)  #发送短信通知

        if @user.save
          #注册成功将验证码设置为过期
          validate.updated_at = Time.now - 10.minute
          validate.save

          @order = @user.create_signup(product) if product
          @msg   = "报名成功"
          session[:user_id] = @user.id
          
          @user = User.get @user.id
          render 'v1/user'
        else
          {:status => :failure, :msg => '注册失败'}.to_json
        end
        
      else
        {:status => :failure, :msg => '该手机号已注册，请直接登录'}.to_json
      end

    end

    #七牛请求token 
    get :uptoken do 
      token_item = ParamsConfig.first(:name=>'qiniu_policy')
      if token_item.nil? || token_item.updated_at+50.minute < Time.now
          token_item              = ParamsConfig.first_or_create(:name=>'qiniu_policy')
          put_policy              = Qiniu::Auth::PutPolicy.new(CustomConfig::QINIUBUCKET)
          put_policy.detect_mime  = 1
          uptoken                 = Qiniu::Auth.generate_uptoken(put_policy)
          token_item.value        = uptoken
          token_item.save
      end

      {:uptoken => token_item.value, :expired => (token_item.updated_at+50.minute).strftime('%Y-%m-%d %H:%I:%S') }.to_json
    end

    #学员反馈
    post :feedbacks, :provides => [:json] do 
      @feedback = Feedback.first_or_create(:user_id => @user.id, :content => params[:content])
      if @feedback
        {:status => :success, :content => @feedback.content}.to_json
      else
        {:status => :failure, :msg => @feedback.errors.full_messages.join(','), :err_code => 4001}.to_json
      end
    end

    #static page
    get :about, :provides => [:html] do 
      render 'v1/static_pages/about'
    end

    get :hospitals, :provides => [:json] do 
      @hospitals = Hospital.all
      @total     = @hospitals.count
      @hospitals = @hospitals.paginate(:page => params[:page], :per_page => 20) 
      render 'v1/hospitals'
    end

    #个人的历史进度
    get :history, :provides => [:html] do 
      key      = "20150607mm"
      token    = Digest::MD5.hexdigest("#{params[:user_id]}#{key}")
      if params[:token] != token
        'token 不正确'
      else
        render 'v1/static_pages/history'
      end
    end

    get :city_list, :provides => [:json] do 
      JSON.parse(city_list).to_json
    end

    get :questions, :provides => [:json] do 
      @questions = Question.all(:city => params[:city], :show => true)
      render 'v1/questions'
    end

    get :app_config, :provides => [:json] do
      @configs = AppConfig.all(:order=>:weight.desc, :city=>params[:city], :open=>1)
      @total  = @configs.count
      render 'v1/app_configs'
    end

  get :ad, :provides => [:json] do
    @ad = Ad.first(:order=> :pv.desc, :city_id => params[:city])
    render 'v1/ad'
  end
  
end
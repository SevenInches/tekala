# -*- encoding : utf-8 -*-
Tekala::Api.controllers :v1, :users do  
	register WillPaginate::Sinatra
  enable :sessions
  default_latitude  = '24.0000'
  default_longitude = '100.333'
  current_url       = '/api/v1'

  before :except => [:login, :logout, :unlogin, :signup, :hospitals, :validate_sms, :forget_password] do 
    @user = User.get(session[:user_id])
    redirect_to("#{current_url}/unlogin") if @user.nil?
    @exam_type = @user.exam_type == 2 ?  "c2" : 'c1'
  end
  
  get :index, :provides => [:json] do 
  	@user
  	render 'v1/user'
  end

  post :validate_sms, :provides => [:json] do
    if !empty?(params[:mobile])
      validate         = UserValidate.first_or_create(:mobile => params[:mobile])
      validate.code    = rand(1111..9999)
      sms = Sms.new(:content => "验证码：#{validate.code}，本验证码10分钟内有效。", :member_mobile => validate.mobile)
      if validate.save && sms.validate
          {:status => :success, :msg => '已发送，请注意查收'}.to_json
      else
          {:status => :failure, :msg => '验证短信未能发送成功，请联系客服'}.to_json
      end
    else
      {:status => :failure, :msg => '电话号码格式不正确'}.to_json
    end
  end

  #个人资料修改
  put :update, :map => '/v1/users/:user_id', :provides => [:json] do
  	@request_user = User.get params[:user_id]
  	if @request_user == @user
  		@user.name          = params[:name]           if params[:name]
	    @user.nickname      = params[:nickname]       if params[:nickname]
	    @user.id_card       = params[:id_card]        if params[:id_card]
      @user.sex           = params[:sex]            if params[:sex]
	    @user.address       = params[:address]        if params[:address]
	    @user.city          = params[:city]           if params[:city]
	    @user.motto         = params[:motto]          if params[:motto]
	    @user.birthday      = params[:birthday]       if params[:birthday]
	    @user.longitude     = params[:longitude]      if params[:longitude]
	    @user.latitude      = params[:latitude]       if params[:latitude]
    	@user.avatar        = params[:avatar]     		if params[:avatar]
      if !empty?(params[:product_id])
        product = Product.get(params[:product_id])
        if !@user.product_id.present?
          @user.product_id = params[:product_id]
        end
        if @request_user.signup.present?
          @request_user.signup.destroy
        end
        @order = @user.create_signup(product)
      end

	    if @user.save
	      render 'v1/user'
	    else
	      {:status => :failure, :msg => @user.errors.full_messages.join(','), :error_code => 3002 }.to_json
	    end

  	else
  		{:status => :failure, :msg => '您没有修改权限', :err_code => 3001}.to_json
  	end
	end

	put :reset, :map => '/v1/users/:user_id/password', :provides => [:json] do
		@request_user = User.get params[:user_id]
  	if @request_user == @user
	    @user = User.authenticate_by_mobile(@user.mobile, params[:old_password])
	    if @user && !empty?(params[:password])
	      @user.crypted_password = 'modify pwd'
	      @user.password 				 = params[:password]
	      {:status => @user.save ? :success : :failure }.to_json 
	    else
	      {:status => :failure , :msg => '密码错误', :err_code => 3002}.to_json 
	    end
	  else
  		{:status => :failure, :msg => '您没有修改密码的权限', :error_code => 3001}.to_json
	  end
  end

  post :forget_password, :provides => [:json] do 
      @user = User.first(:mobile => params[:mobile])
      if !empty?(params[:mobile]) && @user 
        #验证码是否过期
        validate = UserValidate.first(:mobile => params[:mobile])
        if !(validate && (validate.updated_at + 10.minute > Time.now)  && (validate.code == params[:validate_code]))
          return {:status => :failure, :msg => '验证码错误'}.to_json
        end

        if params[:password]
          @user.crypted_password = 'forget_password'
          @user.password         = params[:password]
          @user.save
        end

        if @user.save
          {:status => 'success', :msg => '重置成功'}.to_json
        else
          {:status => 'failure', :msg => @user.errors.full_messages.json(',')}.to_json
        end

      else
        {:status => :failure, :msg => '该手机号不存在'}.to_json
      end

  end

  get :messages, :provides => [:json] do 
    @messages = Message.all(:user_id => @user.id, :order => :created_at.desc)
    @total    = @messages.count
    @messages = @messages.paginate(:per_page => 20, :page => params[:page])
    render 'v1/messages'
  end

  get :messages_no_reads, :provides => [:json] do
    count = Message.all(:user_id => @user.id, :status => 0).count
    {:status =>:success, :data => count}.to_json
  end

  post :read_messages, :provides => [:json] do
    @messages = @user.messages(:status => 0)
    if @messages.count > 0
      @messages.update(:status => 1)
    end
    return {:status => :success, :msg=>'消息设为已读'}.to_json
  end

  #单独一条设置已读
  post :simple_messages, :provides => [:json] do 
    @message = Message.get(params[:message_id])
    if @message
      @message.status = 1 
      {:status => @message.save ? :success : :failure, :msg => '消息设为已读'}.to_json 
    else
      {:status => :failure, :msg => '消息不存在'}.to_json 
    end
  end

  delete :messages, :provides => [:json] do
    @messages = @user.messages
    {:status => @messages && @messages.destroy ? :success : :failure}.to_json 
  
  end

  delete :messages, :map => '/v1/users/messages/:message_id' , :provides => [:json] do 
    @message = Message.get(params[:message_id])
    {:status => @message && @message.destroy ? :success : :failure}.to_json 
  end

end
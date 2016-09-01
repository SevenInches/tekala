# -*- encoding : utf-8 -*-
Tekala::Future.controllers :v1 do

	register WillPaginate::Sinatra
  enable :sessions

  get :boot, :provides => [:json] do
    date     = Date.today
    token    = Digest::MD5.hexdigest("T#{params[:device_no]}#{date}")
    if params[:token] != token
      {:status => :failure, :msg => 'token 不正确'}.to_json
    else
      device = Device.first(:device_no => params[:device_no],:is_active => true)
      if device.present?
        log = BootLog.new(:device_no => params[:device_no])
        log.result     = true
        log.created_at = Time.now
        if log.save
          {:status => :success, :msg => "设备#{params[:device_no]}启动成功"}.to_json
        end
      end
    end
  end

  post :login, :provides => [:json] do
    date     = Date.today
    token    = Digest::MD5.hexdigest("T#{params[:device_no]}#{date}")
    if params[:token] != token
      {:status => :failure, :msg => 'token 不正确'}.to_json
    else
      device = Device.first(:device_no => params[:device_no],:is_active => true)
      if device.nil?
        {:status => :failure, :msg => '设备未激活'}.to_json
      else
        @user = User.authenticate_by_mobile(params[:mobile], params[:password])
        if @user.present?
          session[:user_id] = @user.id
          time_gap = (Time.now - (15*60))..(Time.now + (15*60))
          if @user.orders.first(:book_time => time_gap)
            log = LoginLog.new(:user_id => @user.id)
            log.device_no  = params[:device_no]
            log.school_id  = @user.school_id
            log.login_type = 2 #账号登录
            log.created_at = Time.now
            if log.save
              {:status => :success, :msg => '登录成功'}.to_json
            end
          else
            {:status => :failure, :msg => '没有约车订单或已错过约车时间'}.to_json
          end
        else
          {:status => :failure, :msg => '登录失败'}.to_json
        end
      end
    end
  end

  get :logout, :provides => [:json] do
    session[:user_id] = nil
    {:status => :success, :msg => '成功退出登陆'}.to_json
  end

  get :unlogin, :provides => [:json] do
    {:status => :failure, :msg => '未登录'}.to_json
  end

  get :test do
    {:a => 1}.to_json
  end

end

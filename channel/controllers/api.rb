#渠道版
Tekala::Channel.controllers :v1 do

  register WillPaginate::Sinatra
  enable :sessions
  Rabl.register!

  before :except => [:login, :unlogin, :logout] do
    if session[:channel_id]
      @channel = Channel.get(session[:channel_id])
    else
      redirect_to(url(:v1, :unlogin))
    end
  end

  post :login, :provides => [:json] do
    @channel = Channel.authenticate(params[:phone], params[:password])
    if @channel
      session[:channel_id] = @channel.id
      @channel_id = @channel.id
      render 'channel'
    else
      {:status => :failure, :msg => '登录失败'}.to_json
    end
  end

  post :logout, :provides => [:json] do
    session[:channel_id] = nil
    {:status => :success, :msg => '退出成功'}.to_json
  end

  get :unlogin, :provides => [:json] do
    {:status => :failure, :msg => '未登录'}.to_json
  end

  put :password, :provides => [:json] do
    if params[:old_password].present? && params[:new_password].present?
      if @channel.has_password?(params[:old_password])
        password = ::BCrypt::Password.create(params[:new_password])
        if @channel.update(:crypted_password => password)
          {:status => :success, :msg => '密码修改成功'}.to_json
        else
          {:status => :failure, :msg => @channel.errors.first.first}.to_json
        end
      else
        {:status => :failure, :msg => '原密码错误'}.to_json
      end
    else
      {:status => :failure, :msg => '参数错误'}.to_json
    end
  end

  get :acting_for, :provides => [:json] do
    @agencies = Agency.all(:channel_id => @channel.id)
    if @agencies
      render 'acting_for'
    else
      {:status => :failure, :msg => '加载所代理出错'}
    end
  end

  get :index, :provides => [:json] do
    @channel_id = @channel.id
    render 'channel'
  end

  get :income_details, :provides => [:json] do
    pay_status = [2, 3, 4]

    if params[:start_date].present? && params[:end_date].present?
      start_date = params[:start_date].to_date
      end_date = params[:end_date].to_date
      date_range = start_date .. end_date
      @orders = Order.all(:created_at => date_range, :channel_id => @channel.id, :status => pay_status)
    else
      month_beginning = Date.strptime(Time.now.beginning_of_month.to_s, '%Y-%m-%d')
      this_month = month_beginning .. Date.tomorrow
      @orders = Order.all(:created_at => this_month, :channel_id => @channel.id, :status => pay_status)
    end

    unless @orders.blank?
      render 'income_details'
    else
      {:status => :failure, :msg => '这样的日期范围里没有收入'}.to_json
    end
  end

  get :share, :provides => [:json], :map => '/v1/acting_for/:agency_id/share' do
    # http://www.tekala.cn/m/product/24?back=http%3A%2F%2Fmain%2Fm%2F11%2Fproducts%3Fback%3Dhttp%253A%252F%252Fmain%252Fm%252F11
    # http://www.tekala.cn/m/product/24?back=http://main/m/11/products?back=http://main/m/11
    # http://www.tekala.cn/m/product/24?back=24?back=24
    # http://localhost:9292/channel/v1/acting_for/2/weChat_share
    # 没有back参数会崩溃！
    url = 'http://www.tekala.cn/m/product/'
    agency = Agency.get params[:agency_id]
    return {:status => :failure, :msg => '返回URL失败'}.to_json if agency.nil?

    product_id = agency.product_id
    url += product_id.to_s + "?back=http://main/m/11/products?back=http://main/m/11?channel_id=#{agency.channel_id}" # 事实上，不太清楚back是否应该是如此，此处需要多加交流//与理解
    return {:status => :success, :url => url, :msg => '返回URL成功'}.to_json
  end

  get :hot_messages, :map => '/v1/messages/hot', :provides => [:json] do
    @messages  = MessageCard.all(:order => [:created_at.desc, :weight.desc], :school_id => @channel.school_id, :limit => 5)
    @total  =  @messages.count
    render 'messages'
  end

  get :messages, :map => '/v1/messages', :provides => [:json] do
    @messages  =  MessageCard.all(:order => [:created_at.desc, :weight.desc], :school_id => @channel.school_id)
    @total     =  @messages.count
    @messages  =  @messages.paginate(:per_page => 20, :page => params[:page])
    render 'messages'
  end

  put :message, :map => '/v1/messages/:message_id', :provides => [:json] do
    msg = MessageCard.get(params[:message_id])
    if msg.present?
      msg.click_num += 1
      if msg.save
        {:status => :success, :msg => '消息更新'}.to_json
      end
    else
      {:status => :failure, :msg => '消息不存在'}.to_json
    end
  end

end
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

end
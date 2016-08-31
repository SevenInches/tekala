Tekala::Master.controllers :device do
  before do
    @title = '设备管理'
    @user_name = Account.first(:id => session[:account_id])[:email]
    if !session[:account_id]
      redirect_to(url(:login, :index))
    end
  end

  get :index do
    render 'device/index'
  end

  get :new do
    render "/news/new"
  end

end
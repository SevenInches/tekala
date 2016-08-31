Tekala::Master.controllers :base do
  before do
    @user_name = Account.first(:id => session[:account_id])[:email]
    if !session[:account_id]
      redirect_to(url(:login, :index))
    end
  end

  get :index, :map => "/" do
    @title = '特快拉后台'
    render 'index/index'
  end

end

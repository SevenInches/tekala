Tekala::Master.controllers :base do
  before do
    if session[:account_id]
      render 'index/index'
    else
      redirect_to(url(:login, :index))
    end
  end

  get :index, :map => "/" do
    render 'index/index'
  end

end

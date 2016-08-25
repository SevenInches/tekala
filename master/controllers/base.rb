Tekala::Master.controllers :base do
  before do
    if !session[:account_id]
      redirect_to(url(:login, :index))
    end
  end

  get :index, :map => "/" do
    p session[:account_id]
    render 'index/index'
  end

end

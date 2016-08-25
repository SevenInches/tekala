Tekala::Master.controllers :login do
  get :index do
    render 'login/index',nil, :layout => false
  end

  post :validation do
    account = Account.authenticate(params[:emails], params[:password])
    if account.present?
      # set_current_account(account)
      session[:account_id] = account[:id]
      redirect_to(url(:base, :index))
    else
      # params[:email] = h(params[:email])
      # flash.now[:error] = pat('login.error')
      redirect_to(url(:login, :index))
    end
  end

  get :logout do
    # set_current_account(nil)
    session[:account_id] = nil
    redirect_to(url(:login, :index))
  end

end


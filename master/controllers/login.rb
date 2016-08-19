Tekala::Master.controllers :login do
  get :index do
    render 'login/index',nil, :layout => false
  end

  post :create do
    user = User.authenticate(params[:school], params[:phone], params[:password])
    p role_user
    if role_user.present?
      set_current_account(role_user)
      session[:role_id] = role_user.role_id
      session[:role_user_id] = role_user.id
      session[:school_no] = params[:school]
      session[:mobile]    = params[:phone].to_i
      session[:school_id] = School.first(:school_no => params[:school]).id
      redirect url(:base, :index)
    else
      params[:school] = h(params[:school])
      params[:phone]  = h(params[:phone])
      flash.now[:error] = pat('login.error')
      render "/login/index"
    end
  end

  post :validation do
    if account = Account.authenticate(params[:emails], params[:password])
      # set_current_account(account)
      session[:account_id] = account[:id]
      render "index/index"
    else
      # params[:email] = h(params[:email])
      # flash.now[:error] = pat('login.error')
      redirect_to(url(:login, :index))
    end
  end

  get :logout do
    # set_current_account(nil)
    session[:account_id] = nil
    redirect url(:login, :index)
  end

end


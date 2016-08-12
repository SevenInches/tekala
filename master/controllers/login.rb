Tekala::Master.controllers :login do
  get :index do
    render 'login/index',nil, :layout => false
  end

end


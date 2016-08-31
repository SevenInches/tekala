Tekala::Master.controllers :menu do
  before do
    @user_name = Account.first(:id => session[:account_id])[:email]
    if !session[:account_id]
      redirect_to(url(:login, :index))
    end
  end

  get :index do
    @title  = '菜单管理'
    @menus  = Subpart.all(:order => :weight)
    render "/menu/index"
  end

  get :edit ,:with => :id do
    @title  = '菜单编辑'
    @menu  = Subpart.first(:id => params[:id])
    render "/menu/edit"
  end

  post :update,:with => :id do
    @menu = Subpart.get(params[:id])
    if @menu
      params[:user].each do |param|
        @menu[param[0]] = param[1] if param[1].present?
      end
      if @menu.save
        # flash[:success] = pat(:update_success, :model => 'Menu', :id =>  "#{params[:id]}")
        redirect(url(:menu, :index))
      else
        # flash.now[:error] = pat(:update_error, :model => 'Menu')
        render 'menu/edit/' + @menu.id
      end
    else
      # flash[:success] = pat(:update_success, :model => 'Menu', :id =>  "#{params[:id]}")
      halt 404
    end
    redirect url(:menu, :index)
  end

  get :destory,:with => :id do
    menu = Subpart.first(:id => params[:id])
    if menu && menu.destroy
      #flash[:success] = pat(:delete_success, :model => 'Menu', :id => "#{params[:id]}")
    else
      #flash[:error] = pat(:delete_error, :model => 'Menu')
    end
    redirect url(:menu, :index)
  end

  get :new do
    render "/menu/new"
  end

  post :create do
    menu = Subpart.new(params[:user])
    menu[:id] = Subpart.last[:id] + 1
    menu[:weight] = Subpart.last[:weight] + 1
    if menu.save
      # flash[:success] = pat(:create_success, :model => 'Menu')
    else
      # flash[:error] = pat(:create_error, :model => 'Menu')
    end
    redirect url(:menu, :index)
  end

  post :update_weight, :map => '/menu/update_weight',:provides => [:json] do
    data = params[:data]
    data.each do |item|
      menu = Subpart.first(:id => item[1][:id])
      menu[:weight] = item[1][:weight]
      menu.save
    end
  end

end
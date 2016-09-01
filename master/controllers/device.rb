Tekala::Master.controllers :device do
  before do
    @title = '设备管理'
    @user_name = Account.first(:id => session[:account_id])[:email]
    if !session[:account_id]
      redirect_to(url(:login, :index))
    end
  end

  get :index do
    @devices = Device.all
    @devices = @devices.paginate(:page => params[:page],:per_page => 20)
    render 'device/index'
  end

  get :new do
    render 'device/new'
  end

  post :create do
    device = Device.new(params[:device])
    device.created_at = Time.now
    device.is_active  = false
    device.save
    redirect_to(url(:device, :index))
  end

  get :destroy, :with => :id do
    device = Device.get(params[:id])
    if device
      device.destroy
      redirect_to(url(:device, :index))
    else
      halt 404
    end
  end

  get :edit, :with => :id do
    @device = Device.get(params[:id])
    if @device
      render 'device/edit'
    else
      halt 404
    end
  end

  post :update, :with => :id do
    @device = Device.get(params[:id])
    @device[:updated_at] = Time.now
    if @device
      params[:device].each do |param|
        @device[param[0]] = param[1] if param[1].present?
      end
      if @device.save
        redirect(url(:device, :index))
      else
        render 'device/edit'
      end
    else
      halt 404
    end
  end

end
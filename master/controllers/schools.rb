Tekala::Master.controllers :schools do
  before do
    @user_name = Account.first(:id => session[:account_id])[:email]
    if !session[:account_id]
      redirect_to(url(:login, :index))
    end
  end

  get :index do
    @title = "驾校管理"
    @schools = School.all
    @schools = @schools.all(:name => params[:name]) if params[:name].present?
    @schools = @schools.paginate(:page => params[:page],:per_page => 20)
    render 'schools/index'
  end

  get :new do
    @school = School.new
    render 'schools/new'
  end

  post :create do
    @school = School.new(params[:school])
    if @school.save
      flash[:success] = pat(:create_success, :model => 'School')
      redirect(url(:schools, :index))
    else
      render 'schools/new'
    end
  end

  get :edit, :with => :id do
    @title = '驾校编辑'
    @school = School.get(params[:id])
    if @school
      render 'schools/edit'
    else
      flash[:warning] = pat(:create_error, :model => 'School', :id => "#{params[:id]}")
      halt 404
    end
  end

  put :update, :with => :id do
    @title  = '驾校编辑'
    @school = School.get(params[:id])
    if @school
      if @school.update(params[:school])
        @school.update(:content => params[:content]) if params[:content].present?
        flash[:success] = pat(:update_success, :model => 'School', :id =>  "#{params[:id]}")
        redirect(url(:schools, :index))
      else
        flash.now[:error] = pat(:update_error, :model => 'School')
        render 'schools/edit'
      end
    else
      flash[:warning] = pat(:update_warning, :model => 'School', :id => "#{params[:id]}")
      halt 404
    end
  end

  delete :destroy, :with => :id do
    @title = "Schools"
    school = School.get(params[:id])
    if school
      if school.destroy
        flash[:success] = pat(:delete_success, :model => 'School', :id => "#{params[:id]}")
      else
        flash[:error] = pat(:delete_error, :model => 'School')
      end
      redirect url(:schools, :index)
    else
      flash[:warning] = pat(:delete_warning, :model => 'School', :id => "#{params[:id]}")
      halt 404
    end
  end

  delete :destroy_many do
    @title = "Schools"
    unless params[:school_ids]
      flash[:error] = pat(:destroy_many_error, :model => 'School')
      redirect(url(:schools, :index))
    end
    ids = params[:school_ids].split(',').map(&:strip)
    schools = School.all(:id => ids)

    if schools.destroy

      flash[:success] = pat(:destroy_many_success, :model => 'Schools', :ids => "#{ids.to_sentence}")
    end
    redirect url(:schools, :index)
  end

  get :open do
    school = School.get params[:id]
    school.is_open = !school.is_open
    if school.save
      flash[:success] = '驾校状态修改成功'
    else
      flash[:success] = '驾校状态修改失败'
    end
    redirect(url(params[:back]))
  end
end

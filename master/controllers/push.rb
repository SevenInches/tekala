Tekala::Master.controllers :push do
  before do
    @user_name = Account.first(:id => session[:account_id])[:email]
    if !session[:account_id]
      redirect_to(url(:login, :index))
    end
  end

  get :index do
    @title = "推送管理"
    @pushs = Push.all
    @pushs = @pushs.paginate(:page => params[:page],:per_page => 20)
    render 'push/index'
  end

  post :create do
    @push = Push.new(params[:push])
    if @push.save
      # flash[:success] = pat(:create_success, :model => 'Push')
      redirect(url(:push, :index))
    else
      render 'push/index'
    end
  end

  get :edit, :with => :id do
    @title = pat(:edit_title, :model => "school #{params[:id]}")
    @school = School.get(params[:id])
    if @school
      render 'schools/edit'
    else
      flash[:warning] = pat(:create_error, :model => 'School', :id => "#{params[:id]}")
      halt 404
    end
  end

  put :update, :with => :id do
    @title = pat(:update_title, :model => "school #{params[:id]}")
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

  get :destroy, :with => :id do
    push = Push.get(params[:id])
    if push
      if push.destroy
        #flash[:success] = pat(:delete_success, :model => 'Push', :id => "#{params[:id]}")
      else
        #flash[:error] = pat(:delete_error, :model => 'Push')
      end
      redirect url(:push, :index)
    else
      #flash[:warning] = pat(:delete_warning, :model => 'Push', :id => "#{params[:id]}")
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

  get :resend, :with => :id do

  end
end

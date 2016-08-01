Tekala::Admin.controllers :users do

  get :index do
    @title = "Users"
    @users = User.all(:order =>[:created_at.desc])
    @users = @users.all(:name.like => "%#{params[:name]}%")    if params[:name].present?
    @users = @users.all(:mobile => params[:mobile])            if params[:mobile].present?
    @users = @users.all(:school_id => params[:school_id])      if params[:school_id].present?
    @users = @users.all(:product_id => params[:product_id])    if params[:product_id].present?
    @users = @users.all(:status_flag => params[:status_flag])  if params[:status_flag].present?
    @users = @users.all(:exam_type => params[:exam_type])      if params[:exam_type].present?

    @users  = @users.paginate(:page => params[:page], :per_page => 10)
    render 'users/index'
  end

  get :new do
    @user = User.new
    render 'users/new'
  end

  post :create do
    @user = User.new
    params[:user].each do |param|
        @user[param[0]] = param[1] if param[1].present?
    end
    if params[:avatar].present?
      pid = AppLaunchAd.max(:id).nil? ? 1 : AppLaunchAd.max(:id)+1
      tempfile = params[:avatar][:tempfile]
      ext = File.extname(params[:avatar][:filename])
      pic = send_picture(tempfile, ext, 'qiniu_user')
      avatar = upload_qiniu(pic, 'tekala_user_'+pid.to_s)
      @user['avatar'] =  CustomConfig::QINIUURL+ avatar['key'].to_s
    end
    if @user.save!
      flash[:success] = pat(:create_success, :model => 'User')
      redirect(url(:users, :index))
    else
      render 'users/new'
    end
  end

  get :edit, :with => :id do
    @title = pat(:edit_title, :model => "user #{params[:id]}")
    @user = User.get(params[:id])
    if @user
      render 'users/edit'
    else
      flash[:warning] = pat(:create_error, :model => 'User', :id => "#{params[:id]}")
      halt 404
    end
  end

  put :update, :with => :id do
    @title = pat(:update_title, :model => "user #{params[:id]}")
    @user = User.get(params[:id])
    if @user
      params[:user].each do |param|
        @user[param[0]] = param[1] if param[1].present?
      end
      if params[:avatar].present?
        pid = User.max(:id).nil? ? 1 : User.max(:id)+1
        tempfile = params[:avatar][:tempfile]
        ext = File.extname(params[:avatar][:filename])
        pic = send_picture(tempfile, ext, 'qiniu_user')
        avatar = upload_qiniu(pic, 'tekala_user_'+pid.to_s)
        @user.update( :avatar => CustomConfig::QINIUURL+ avatar['key'].to_s)
      end
      if @user.save
        flash[:success] = pat(:update_success, :model => 'User', :id =>  "#{params[:id]}")
        redirect(url(:users, :index))
      else
        flash.now[:error] = pat(:update_error, :model => 'User')
        render 'users/edit'
      end
    else
      flash[:warning] = pat(:update_warning, :model => 'User', :id => "#{params[:id]}")
      halt 404
    end
  end

  delete :destroy, :with => :id do
    @title = "Users"
    user = User.get(params[:id])
    if user
      if user.destroy
        flash[:success] = pat(:delete_success, :model => 'User', :id => "#{params[:id]}")
      else
        flash[:error] = pat(:delete_error, :model => 'User')
      end
      redirect url(:users, :index)
    else
      flash[:warning] = pat(:delete_warning, :model => 'User', :id => "#{params[:id]}")
      halt 404
    end
  end

  delete :destroy_many do
    @title = "Users"
    unless params[:user_ids]
      flash[:error] = pat(:destroy_many_error, :model => 'User')
      redirect(url(:users, :index))
    end
    ids = params[:user_ids].split(',').map(&:strip)
    users = User.all(:id => ids)

    if users.destroy

      flash[:success] = pat(:destroy_many_success, :model => 'Users', :ids => "#{ids.to_sentence}")
    end
    redirect url(:users, :index)
  end

  get :export do

    @users  = User.all(:order => :id.desc)
    @users  = @users.all(:name.like => "%#{params[:name]}%")    if params[:name].present?
    @users  = @users.all(:mobile  => params[:mobile])           if params[:mobile].present?
    @users  = @users.all(:status_flag => params[:status_flag])  if params[:status_flag].present?

    @users  = @users.all(:exam_type => params[:exam_type]) if params[:exam_type].present?
    @users  = @users.all(:school_id => params[:school_id]) if params[:school_id].present?
    @users  = @users.all(:product_id => params[:product_id]) if params[:product_id].present?

    book = Spreadsheet::Workbook.new
    sheet = book.create_worksheet
    sheet[0,0]    = "#id"
    sheet[0,1]    = "用户"
    sheet[0,2]    = "手机号"
    sheet[0,3]    = "状态"
    sheet[0,4]    = "驾考类型"
    sheet[0,5]    = "驾校"
    sheet[0,6]    = "班别"
    sheet[0,7]    = "城市"
    sheet[0,8]    = "创建时间"
    format = Spreadsheet::Format.new :color => :blue,
                                     :weight => :bold,
                                     :size => 15
    sheet.row(0).default_format = format

    @users.each_with_index do |user,index|
      sheet[index+1,0]    = user.id
      sheet[index+1,1]    = user.name
      sheet[index+1,2]    = user.mobile
      sheet[index+1,3]    = user.status_flag_word
      sheet[index+1,4]    = user.exam_type_word
      sheet[index+1,5]    = user.school.present? ? user.school.name : ''
      sheet[index+1,6]    = (user.signup.present? && user.signup.product.present?) ? user.signup.product.name : ''
      sheet[index+1,7]    = user.city.present? ? user.city.name : ''
      sheet[index+1,8]    = user.created_at.present? ? user.created_at.strftime('%m月%d日 %H:%M') : ''
    end

    output_file_name = "user_#{Time.now.to_i}.xls"
    book.write "public/uploads/#{output_file_name}"

    redirect "/uploads/#{output_file_name}"

  end

end

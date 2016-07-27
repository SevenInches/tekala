Tekala::Admin.controllers :pushes do
  get :index do
    @title = "pushes"
    @pushes = Push.all
    render 'pushes/index'
  end

  get :new do
    @push = Push.new
    render 'pushes/new'
  end

  post :create do
    @push = Push.new
    params[:push].each do |index,push|
      @push[index] = push if push.present?
    end
    if params[:editions].present?
      @push.editions = params[:editions].join(":")
    end
    if @push.save!
      flash[:success] = pat(:create_success, :model => 'Push')
      redirect(url(:pushes, :index))
    else
      puts @push.attributes
      puts @push.errors.
      render 'pushes/new'
    end
  end

  get :edit, :with => :id do
    @title = pat(:edit_title, :model => "Push #{params[:id]}")
    @push = Push.get(params[:id])
    if @push
      render 'pushes/edit'
    else
      flash[:warning] = pat(:create_error, :model => 'Push', :id => "#{params[:id]}")
      halt 404
    end
  end

  put :update, :with => :id do
    @title = pat(:update_title, :model => "update #{params[:id]}")
    @push = Push.get(params[:id])
    if @push
      if params[:editions].present?
        params[:push][:editions] = params[:editions].join(":")
      end
      if @push.update(params[:push])
        flash[:success] = pat(:update_success, :model => 'Push', :id =>  "#{params[:id]}")
        redirect(url(:ads, :index))
      else
        flash.now[:error] = pat(:update_error, :model => 'Push')
        render 'pushes/edit'
      end
    else
      flash[:warning] = pat(:update_warning, :model => 'Push', :id => "#{params[:id]}")
      halt 404
    end
  end

  delete :destroy, :with => :id do
    @title = "Push"
    push = Push.get(params[:id])
    if push
      if push.destroy
        flash[:success] = pat(:delete_success, :model => 'Push', :id => "#{params[:id]}")
      else
        flash[:error] = pat(:delete_error, :model => 'Push')
      end
      redirect url(:pushes, :index)
    else
      flash[:warning] = pat(:delete_warning, :model => 'Push', :id => "#{params[:id]}")
      halt 404
    end
  end

  delete :destroy_many do
    @title = "Push"
    unless params[:push_ids]
      flash[:error] = pat(:destroy_many_error, :model => 'Push')
      redirect(url(:pushes, :index))
    end
    ids = params[:push_ids].split(',').map(&:strip)
    pushes = Push.all(:id => ids)

    if pushes.destroy
      flash[:success] = pat(:destroy_many_success, :model => 'Push', :ids => "#{ids.to_sentence}")
    end
    redirect url(:pushes, :index)
  end

  post :send, :with => :id do
    @title = pat(:send_title, :model => "Push #{params[:id]}")
    push = Push.get(params[:id])
    if push.present?
      if push.editions.present?
          push.editions.split(":").each do |edition|
            key, src= JPush.get_edition(edition)
            JPush.send_channel(push.channel_id, push.message, key, src) if push.channel_id.present?
            JPush.send_version(push.version, push.message, key, src)    if push.version.present?
            JPush.send_school(push.school_id, push.message, key, src)   if push.school_id.present?
            JPush.send_status(push.user_status, push.message, key, src) if push.user_status.present?
          end
        flash[:success] = pat(:send_success, :model => 'Push', :id => "#{params[:id]}")
      end
      redirect url(:pushes, :index)
    end
  end
end
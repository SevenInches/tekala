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
      params[:push].each do |index,push|
        @push[index] = push if push.present?
        @push[index] = nil if push.empty?
      end
      if @push.save
        flash[:success] = pat(:update_success, :model => 'Push', :id =>  "#{params[:id]}")
        redirect(url(:pushes, :index))
      else
        puts @push.errors.to_json
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

  get :send, :with => :id do
    @title = pat(:send_title, :model => "Push #{params[:id]}")
    push = Push.get(params[:id])
    tags = []
    if push.present? && push.editions.present?
        push.editions.split(':').each do |edition|
        tags << 'channel_' + push.channel_id.to_s if push.channel_id.present?
        tags << 'version_' + push.version if push.version.present?
        tags << 'school_'  + push.school_id.to_s if push.school_id.present?
        tags << 'status_'  + push.user_status.to_s if !push.user_status.nil?
        JPush.send_message(tags, push.message, edition)
      end
      flash[:success] = pat(:send_success, :model => 'Push', :id => "#{params[:id]}")
      redirect url(:pushes, :index)
    end
  end

  get :test_1 do
    JPush.order_remind 54
  end

  get :test_2 do
    JPush.order_comment 54
  end

  get :test_3 do
    JPush.tweet_comment 547, 3440, 3464, 'xyz'
  end

  get :test_4 do
    JPush.tweet_like 547, 3440
  end

  get :test_5 do
    JPush.order_cancel 54
  end
end
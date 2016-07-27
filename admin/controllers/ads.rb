Tekala::Admin.controllers :ads do
  get :index do
    @title = "Ads"
    @ads = AppLaunchAd.all
    @ads.all(:channel => params[:channel])  if params[:channel].present?
    render 'ads/index'
  end

  get :new do
    @ad = AppLaunchAd.new
    render 'ads/new'
  end

  post :create do
    @ad = AppLaunchAd.new(params[:app_launch_ad])
    if params[:pic].present?
      pid = AppLaunchAd.max(:id).nil? ? 1 : AppLaunchAd.max(:id)+1
      tempfile = params[:pic][:tempfile]
      ext = File.extname(params[:pic][:filename])
      pic = send_picture(tempfile, ext)
      a = upload_qiniu(pic, 'app_launch_ad_'+pid.to_s)
      @ad.cover_url =  CustomConfig::QINIUURL+ a['key'].to_s
    end
    if @ad.save!
      flash[:success] = pat(:create_success, :model => 'Ad')
      redirect(url(:ads, :index))
    else
      render 'ads/new'
    end
  end

  get :edit, :with => :id do
    @title = pat(:edit_title, :model => "ad #{params[:id]}")
    @ad = AppLaunchAd.get(params[:id])
    if @ad
      render 'ads/edit'
    else
      flash[:warning] = pat(:create_error, :model => 'Ad', :id => "#{params[:id]}")
      halt 404
    end
  end

  put :update, :with => :id do
    @title = pat(:update_title, :model => "update #{params[:id]}")
    @ad = AppLaunchAd.get(params[:id])
    if @ad
      if @ad.update(params[:ad])
        flash[:success] = pat(:update_success, :model => 'AppLaunchAd', :id =>  "#{params[:id]}")
        redirect(url(:ads, :index))
      else
        flash.now[:error] = pat(:update_error, :model => 'AppLaunchAd')
        render 'ads/edit'
      end
    else
      flash[:warning] = pat(:update_warning, :model => 'AppLaunchAd', :id => "#{params[:id]}")
      halt 404
    end
  end

  delete :destroy, :with => :id do
    @title = "AppLaunchAds"
    ad = AppLaunchAd.get(params[:id])
    if ad
      if ad.destroy
        flash[:success] = pat(:delete_success, :model => 'AppLaunchAd', :id => "#{params[:id]}")
      else
        flash[:error] = pat(:delete_error, :model => 'AppLaunchAd')
      end
      redirect url(:ads, :index)
    else
      flash[:warning] = pat(:delete_warning, :model => 'AppLaunchAd', :id => "#{params[:id]}")
      halt 404
    end
  end

  delete :destroy_many do
    @title = "AppLaunchAds"
    unless params[:ad_ids]
      flash[:error] = pat(:destroy_many_error, :model => 'AppLaunchAd')
      redirect(url(:ads, :index))
    end
    ids = params[:ad_ids].split(',').map(&:strip)
    ads = AppLaunchAd.all(:id => ids)

    if ads.destroy

      flash[:success] = pat(:destroy_many_success, :model => 'AppLaunchAds', :ids => "#{ids.to_sentence}")
    end
    redirect url(:ads, :index)
  end

  get :status do
    ad = AppLaunchAd.get params[:id]
    ad.status = !ad.status
    if ad.save!
      flash[:success] = '广告状态修改成功'
    else
      flash[:success] = '广告状态修改失败'
    end
    redirect(url(params[:back]))
  end

end


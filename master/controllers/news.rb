Tekala::Master.controllers :news do
  before do
    @title = '新闻管理'
    @user_name = Account.first(:id => session[:account_id])[:email]
    if !session[:account_id]
      redirect_to(url(:login, :index))
    end
  end

  get :index do
    @news = News.all
    @news = @news.paginate(:page => params[:page],:per_page => 20)
    render 'news/index'
  end

  get :new do
    render "/news/new"
  end

  post :create do
    @news   = News.new(params[:news])
    @news.school_id = session[:school_id]
    @school = School.all
    if @news.save
      @school.each do |item|
        card = MessageCard.new(:school_id => item[:id])
        card.title      = @news.title
        card.tag        = '特快拉'
        card.created_at = Time.now
        card.url        = MessageCard::HOME + 'news_card/' + @news.id.to_s
        card.save
      end
      # flash[:success] = pat(:create_success, :model => 'News')
    end
    redirect(url(:news, :index))
  end

  get :destory, :with => :id do
    new = News.get(params[:id])
    if new
      new.destroy
      cards = MessageCard.all(:title => new[:title])
      if cards
        cards.destroy
      end
    end
    redirect(url(:news, :index))
  end

  get :edit, :with => :id do
    @news = News.get(params[:id])
    if @news
      render 'news/edit'
    else
      # flash[:warning] = pat(:create_error, :model => 'article', :id => "#{params[:id]}")
      halt 404
    end
  end

  post :update, :with => :id do
    @new = News.get(params[:id])
    if @new
      params[:news].each do |param|
        @new[param[0]] = param[1] if param[1].present?
      end
      if @new.save
        redirect(url(:news, :index))
      else
        render 'news/edit'
      end
    else
      halt 404
    end
  end

  get :detail, :with => :id do
    @new = News.get(params[:id])
    @new.view_count = @new.view_count + 1
    if @new
      @new.save
      render 'news/detail'
    else
      halt 404
    end
  end
end


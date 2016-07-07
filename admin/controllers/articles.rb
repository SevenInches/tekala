Szcgs::Admin.controllers :articles do
  get :index do
    @title = "Articles"
    @articles = Article.all
    @articles = @articles.all(:type => params[:type]) if params[:type]
    render 'articles/index'
  end

  get :new do
    @title = pat(:new_title, :model => 'article')
    @article = Article.new
    render 'articles/new'
  end

  get :content do 
    @article = Article.get params[:id]
    render 'articles/content', :layout => false
  end


  post :content do 
    @article = Article.get params[:id]
    @article.content = params[:content].html_safe
    @article.save
    {:status => @article.save ? :success : :failure }.to_json
  end

  post :create do
    @article = Article.new(params[:article])
    if @article.save
      @title = pat(:create_title, :model => "article #{@article.id}")
      flash[:success] = pat(:create_success, :model => 'Article')
      params[:save_and_continue] ? redirect(url(:articles, :index)) : redirect(url(:articles, :edit, :id => @article.id))
    else
      @title = pat(:create_title, :model => 'article')
      flash.now[:error] = pat(:create_error, :model => 'article')
      render 'articles/new'
    end
  end

  get :edit, :with => :id do
    @title = pat(:edit_title, :model => "article #{params[:id]}")
    @article = Article.get(params[:id])
    if @article
      render 'articles/edit'
    else
      flash[:warning] = pat(:create_error, :model => 'article', :id => "#{params[:id]}")
      halt 404
    end
  end

  put :update, :with => :id do
    @title = pat(:update_title, :model => "article #{params[:id]}")
    @article = Article.get(params[:id])
    if @article
      if @article.update(params[:article])
        @article.update(:content => params[:content]) if params[:content].present?
        flash[:success] = pat(:update_success, :model => 'Article', :id =>  "#{params[:id]}")
        params[:save_and_continue] ? redirect(url(:articles, :index)) : redirect(url(:articles, :edit, :id => @article.id))
      else
        flash.now[:error] = pat(:update_error, :model => 'article')
        render 'articles/edit'
      end
    else
      flash[:warning] = pat(:update_warning, :model => 'article', :id => "#{params[:id]}")
      halt 404
    end
  end

  delete :destroy, :with => :id do
    @title = "Articles"
    article = Article.get(params[:id])
    if article
      if article.destroy
        flash[:success] = pat(:delete_success, :model => 'Article', :id => "#{params[:id]}")
      else
        flash[:error] = pat(:delete_error, :model => 'article')
      end
      redirect url(:articles, :index)
    else
      flash[:warning] = pat(:delete_warning, :model => 'article', :id => "#{params[:id]}")
      halt 404
    end
  end

  delete :destroy_many do
    @title = "Articles"
    unless params[:article_ids]
      flash[:error] = pat(:destroy_many_error, :model => 'article')
      redirect(url(:articles, :index))
    end
    ids = params[:article_ids].split(',').map(&:strip)
    articles = Article.all(:id => ids)
    
    if articles.destroy
    
      flash[:success] = pat(:destroy_many_success, :model => 'Articles', :ids => "#{ids.to_sentence}")
    end
    redirect url(:articles, :index)
  end
end

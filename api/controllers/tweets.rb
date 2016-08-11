Tekala::Api.controllers :v1, :tweets do  
	register WillPaginate::Sinatra
  enable :sessions
  current_url = '/api/v1'

  before :except => [:login, :logout, :unlogin, :signup, :hospitals] do 
    @user = User.get(session[:user_id])
    $school_remark = 'school_' + @user.school_id.to_s
    redirect_to("#{current_url}/unlogin") if @user.nil?
  end

  get :index, :provides =>[:json] do
  	last_id = params[:last_id].to_i
    if last_id > 0
      current_tweet = Tweet.get(last_id)
      updated_at    = current_tweet.updated_at
      @tweets = Tweet.all(:order => :updated_at.desc, :updated_at.lt => updated_at, :limit =>20) 
    else
      @tweets = Tweet.all(:order => :updated_at.desc, :limit =>20)
    end
    @total  = Tweet.count
    render 'v1/tweets'
  end

  post :index, :provides => [:json] do 
  	@tweet = Tweet.new
    @tweet.user_id = @user.id
    @tweet.content = params[:content]
    @tweet.city    = @user.city_id if @user.city_id.present?
    if !params[:content].nil? && @tweet.save
	    (1..9).each do |i|
	    	TweetPhoto.create(:tweet_id => @tweet.id, :user_id => @user.id, :url => params["photo#{i}"]) if params["photo#{i}"]  
      end
      $redis.lpush $school_remark, '学员动态'
	  	render 'v1/tweet'
	  else 
	  	{:status => :failure, :msg => @tweet.errors.full_messages.join(',')}.to_json
    end
  end

  get :list, :map => 'v1/tweets/list/:user_id', :provides => [:json] do
    @tweets = Tweet.all(:user_id => params[:user_id])
    if @tweets
      @total  = @tweets.count
      render 'v1/tweets'
    else
      {:status => :failure, :msg => '未能找到该用户的tweet'}.to_json
    end
  end

  get :show, :map => 'v1/tweets/:tweet_id', :provides => [:json] do 
    @tweet = Tweet.get(params[:tweet_id])
    if @tweet 
      render 'v1/tweet'
    else
      {:status => :failure, :msg => '未能找到该tweet'}.to_json
    end
  end

  delete :index, :map => 'v1/tweets/:tweet_id', :provides => [:json] do 
    @tweet = Tweet.first(:id => params[:tweet_id], :user_id => @user.id )
    if @tweet && @tweet.user_id = @user.id
      @tweet.tweet_photos.destroy
      @tweet.tweet_comments.destroy
      @tweet.tweet_likes.destroy
      { :status => @tweet.destroy ? :success : :failure }.to_json
    else
      { :status => :failure, :msg => '该评论已删除' }.to_json
    end
  end

  get :comments, :map => 'v1/tweets/:tweet_id/comments', :provides => [:json] do 
  	last_id   = params[:last_id].to_i
    @comments = TweetComment.all(:tweet_id => params[:tweet_id], :order => :created_at.asc, :limit =>20)
    @comments = @comments.all(:city => params[:city]) if params[:city]
    @comments = @comments.all(:order => :created_at.asc, :id.gt => last_id, :limit =>20) if last_id > 0
    @total    = TweetComment.count
  	render 'v1/tweet_comments'
  end

  post :comments, :map => 'v1/tweets/:tweet_id/comments', :provides => [:json] do 
  	@comment = TweetComment.new
  	@comment.content       = params[:content]
  	@comment.tweet_id      = params[:tweet_id]
  	@comment.reply_user_id = params[:reply_user_id] if params[:reply_user_id]
  	@comment.user_id    	 = @user.id
  	if @comment.save
      tweet = Tweet.get params[:tweet_id]
      tweet.updated_at = Time.now
      tweet.save
     
      JPush::tweet_comment(params[:tweet_id], @user.id, params[:reply_user_id], @comment.content)
  		render 'v1/tweet_comment'
  	else
  		{:status => :failure}.to_json
  	end
  end

  delete :comment, :map => 'v1/tweets/:tweet_id/comments/:comment_id', :provides => [:json] do
    @comment = TweetComment.first(:id => params[:comment_id], :user_id => @user.id, :tweet_id => params[:tweet_id] )
    if @comment
      { :status => @comment.destroy ? :success : :failure }.to_json
    else
      {:status => :failure, :msg => '该评论已经删除' }.to_json
    end
  end

  post :like, :map => 'v1/tweets/:tweet_id/like', :provides => [:json] do 
  	@like = TweetLike.first(:tweet_id => params[:tweet_id], :user_id => @user.id)
  	if @like 
  		if @like.destroy
        {:status => :success, :liked => false }.to_json
  		else
        {:status => :failure}.to_json
  		end
    else
      @like = TweetLike.new
      @like.tweet_id = params[:tweet_id]
      @like.user_id  = @user.id

      if @like.save
	      tweet   = Tweet.get(params[:tweet_id])
	      tweet.updated_at = Time.now
	      if tweet.save
	        JPush::tweet_like(params[:tweet_id], @user.id)
	        {:status => :success, :liked => true }.to_json
        end
      else
        puts 'e'
      	{:status => :failure}.to_json
      end
  	end
  end

end
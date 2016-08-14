require 'json'
require 'rest-client'

Tekala::TestForStudent.controllers :test_for_student do
  	enable :sessions

  	get :index, :map => '/' do
  		$arr ||= []
   		render 'index'
  	end

  	# 据说登录的post URL要存于一个变量
  	post :login_with_valid_account, :map => '/login_with_valid_account' do
		mobile = '13094442075'
		password = '123456'
		login_url = 'https://www.tekala.cn/api/v1/login'
		@status =  JSON.parse(RestClient.post(login_url, :mobile => mobile, :password => password))["status"]

		$arr << 'login_with_valid_account' if @status == "success"

		redirect_to '/test_for_student/login_with_an_account_not_registered'
	end

	get :login_with_an_account_not_registered, :map => '/login_with_an_account_not_registered' do
		mobile = '1309444207'
		password = '123456'
		login_url = 'https://www.tekala.cn/api/v1/login'
		@status =  JSON.parse(RestClient.post(login_url, :mobile => mobile, :password => password))["status"]

		$arr << 'login_with_an_account_not_registered' if @status == "failure"

		redirect_to '/test_for_student/login_with_a_wrong_password'
	end

	get :login_with_a_wrong_password, :map => '/login_with_a_wrong_password' do
		mobile = '13094442075'
		password = '12345'
		login_url = 'https://www.tekala.cn/api/v1/login'
		@status =  JSON.parse(RestClient.post(login_url, :mobile => mobile, :password => password))["status"]

		$arr << 'login_with_a_wrong_password' if @status == "failure"

		redirect_to '/test_for_student/logout'
	end

	get :logout, :map => '/logout' do
		if $arr.include? 'login_with_valid_account'
			logout_url = 'https://www.tekala.cn/api/v1/logout'
			@status = JSON.parse(RestClient.get(logout_url))["status"]
			$arr << 'logout' if @status == "success"

			redirect_to '/test_for_student/get_questions'
		else
			$arr << 'over'
			redirect_to '/test_for_student'
		end
	end

	get :get_questions, :map => '/get_questions' do
		get_questions_url = 'https://www.tekala.cn/api/v1/questions'
		@status = JSON.parse(RestClient.get(get_questions_url))["status"]
		$arr << 'get_questions' if @status == 'success'

		redirect_to '/test_for_student/edit_user'
	end

	get :edit_user, :map => '/edit_user' do
		@user = User.first
		if @user
			@user.name = '莱'
			@user.nickname = '科'
			@user.sex = '1'
			@user.address = '向南瑞峰'
			@user.avatar = 'https://ruby-china-files.b0.upaiyun.com/user/avatar/16154.jpg!lg'

			$arr << 'edit_user' if @user.save
		end

		redirect_to '/test_for_student/reset_password_with_wrong_origin_password'
	end

	get :reset_password_with_wrong_origin_password, :map => '/reset_password_with_wrong_origin_password' do
		@user = User.first(:mobile => '13094442075')

		if @user
			$arr << 'reset_password_with_wrong_origin_password' unless User.authenticate_by_mobile('13094442075', '12345')

			redirect_to '/test_for_student/reset_password_with_right_origin_password'
		else
			@user = User.new
			@user.mobile = '13094442075'
			@user.password = '123456'
			@user.save

			redirect_to '/test_for_student/reset_password_with_wrong_origin_password'
		end
	end

	get :reset_password_with_right_origin_password, :map => '/reset_password_with_right_origin_password' do
		@user = User.first(:mobile => '13094442075')

		if @user
			if User.authenticate_by_mobile('13094442075', '123456')
				@user.password = '1234567'

				if @user.save
					$arr << 'reset_password_with_right_origin_password'
					@user.password = '123456'
					@user.save
				end
			end
		end

		redirect_to '/test_for_student/post_feedbacks'
	end

	get :post_feedbacks, :map => '/post_feedbacks' do
		begin
			@user = User.first(:mobile => '13094442075')
			if @user
				@feedback = Feedback.first_or_create(:user_id => @user.id, :content =>'lalalala')
				$arr << 'post_feedbacks' if @feedback
			end
		rescue =>e			
		end

		redirect_to '/test_for_student/get_schools'
	end

	get :get_schools, :map => '/get_schools' do
		@status =  JSON.parse(RestClient.get('https://www.tekala.cn/api/v1/schools'))["status"]

		$arr << 'get_schools' if @status == 'success'

		redirect_to '/test_for_student/get_class'
	end

	get :get_class, :map => '/get_class' do
		@status =  JSON.parse(RestClient.get('https://www.tekala.cn/api/v1/school/11'))["status"]

		$arr << 'get_class' if @status == 'success'

		redirect_to '/test_for_student/get_tweets'
	end

	get :get_tweets, :map => '/get_tweets' do
		@tweets = Tweet.all(:order => :updated_at.desc, :limit =>20)
		$arr << 'get_tweets' if @tweets

		redirect_to '/test_for_student/show_comments'
	end

	get :show_comments, :map => '/show_comments' do
		tweet_id = Tweet.first.id
		@comments = TweetComment.all(:tweet_id => tweet_id, :order => :created_at.asc, :limit =>20)

		$arr << 'show_comments' if @comments

		redirect_to '/test_for_student/post_comment'
	end

	get :post_comment, :map => '/post_comment' do
		tweet_id = Tweet.first.id
		@user = User.first(:mobile => '13094442075')
		if @user
			@comment = TweetComment.new
		  	@comment.content = 'lalala'
		  	@comment.tweet_id = tweet_id
		  	@comment.user_id = @user.id
		  	$arr << 'post_comment' if @comment.save
	  	end

		redirect_to '/test_for_student/post_tweets'
	end

	get :post_tweets, :map => '/post_tweets' do
		@user = User.first(:mobile => '13094442075')
		if @user
			@tweet = Tweet.new
			@tweet.user_id = @user.id
			@tweet.content = 'hahaha'
			@tweet.city    = @user.city_id

			if @tweet.save
				TweetPhoto.create(:tweet_id => @tweet.id, :user_id => @user.id, :url => 'https://ruby-china-files.b0.upaiyun.com/user/avatar/16154.jpg!lg')

				$arr << 'post_tweets'
			end
		end

		redirect_to '/test_for_student/post_like_when_not_liked'
	end

	get :post_like_when_not_liked, :map => '/post_like_when_not_liked' do
		tweet_id = Tweet.first.id
		@user = User.first(:mobile => '13094442075')

		if @user
			@like = TweetLike.first(:tweet_id => tweet_id, :user_id => @user.id)
			@like.destroy if @like

			@like = TweetLike.new
			@like.tweet_id = tweet_id
	      		@like.user_id  = @user.id

	      		$arr << 'post_like_when_not_liked' if @like.save
      		end

      		redirect_to '/test_for_student/delete_like_when_liked'
	end

	get :delete_like_when_liked, :map => '/delete_like_when_liked' do
		tweet_id = Tweet.first.id
		@user = User.first(:mobile => '13094442075')

		if @user
			@like = TweetLike.first(:tweet_id => tweet_id, :user_id => @user.id)
			if @like
				$arr << 'delete_like_when_liked' if @like.destroy
			else
				@like = TweetLike.new
				@like.tweet_id = tweet_id
				@like.user_id = @user.id

				redirect_to '/test_for_student/delete_like_when_liked' if @like.save
			end
      		end

      		redirect_to '/test_for_student/delete_my_tweet'
	end

	get :delete_my_tweet, :map => '/delete_my_tweet' do
		@user = User.first(:mobile => '13094442075')

		if @user
			@tweet = Tweet.first(:user_id => @user.id )

			if @tweet
				@tweet.tweet_photos.destroy
		      		@tweet.tweet_comments.destroy
		      		@tweet.tweet_likes.destroy
		      		$arr << 'delete_my_tweet' if @tweet.destroy
			end
		end

		redirect_to '/test_for_student/delete_my_comment'
	end

	get :delete_my_comment, :map => '/delete_my_comment' do
		@user = User.first(:mobile => '13094442075')

		if @user
			@comment = TweetComment.first(:user_id => @user.id)

			$arr << 'delete_my_comment' if @comment.destroy
		end

		$arr << 'over'

		redirect_to '/test_for_student'
	end

	post :clear_test, :map => '/clear_test' do
		$arr = []

		redirect_to '/test_for_student'
	end

end
require 'json'
require 'rest-client'

Tekala::TestForStudent.controllers :test_for_student  do
  enable :sessions

  get :index, :map => '/' do
    $arr ||= []
    $arr << params[:id] unless params[:id].nil?
    render 'index'
  end

  post :login_with_valid_account, :map => '/login_with_valid_account' do
		mobile = '13094442075'
		password = '123456'
		str =  JSON.parse(RestClient.post('https://www.tekala.cn/api/v1/login',
						:mobile => mobile,
						:password => password
                                                 	  ))
		@status = str["status"]

		if @status == "success"
			$arr << 1
		end

		redirect_to '/test_for_student/login_with_an_account_not_registered'
	end

	get :login_with_an_account_not_registered, :map => '/login_with_an_account_not_registered' do
		mobile = '1309444207'
		password = '123456'
		str =  JSON.parse(RestClient.post('https://www.tekala.cn/api/v1/login',
						:mobile => mobile,
						:password => password
                                                 	  ))
		@status = str["status"]

		if @status == "failure"
			$arr << 2
		end

		redirect_to '/test_for_student/login_with_a_wrong_password'
	end

	get :login_with_a_wrong_password, :map => '/login_with_a_wrong_password' do
		mobile = '13094442075'
		password = '12345'
		str =  JSON.parse(RestClient.post('https://www.tekala.cn/api/v1/login',
						:mobile => mobile,
						:password => password
                                                 	  ))
		@status = str["status"]

		if @status == "failure"
			$arr << 3
		end

		redirect_to '/test_for_student/logout'
	end

	get :logout, :map => '/logout' do
		if $arr.include? 1
			@status = JSON.parse(RestClient.get('https://www.tekala.cn/api/v1/logout'))["status"]
			if @status == "success"
				$arr << 4
			end

			redirect_to '/test_for_student/get_questions'
		else
			redirect_to '/test_for_student'
		end
	end

	get :get_questions, :map => '/get_questions' do
		@status = JSON.parse(RestClient.get('https://www.tekala.cn/api/v1/questions'))["status"]
		if @status == 'success'
			$arr << 5
		end

		redirect_to '/test_for_student/edit_user'
	end

	get :edit_user, :map => '/edit_user' do
		@user = User.get(1)
		if @user
			@user.name = '莱'
			@user.nickname = '科'
			@user.sex = '1'
			@user.address = '向南瑞峰'
			@user.avatar = 'https://ruby-china-files.b0.upaiyun.com/user/avatar/16154.jpg!lg'

			if @user.save
				$arr << 6
			end
		end

		redirect_to '/test_for_student/reset_password_with_wrong_origin_password'
	end

	get :reset_password_with_wrong_origin_password, :map => '/reset_password_with_wrong_origin_password' do
		@user = User.first(:mobile => '13094442075')

		if @user
			unless User.authenticate_by_mobile('13094442075', '12345')
				$arr << 7
			end
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
					$arr << 8
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
				if @feedback
					$arr << 9
				end
			end
		rescue =>e			
		end

		redirect_to '/test_for_student/get_schools'
	end

	get :get_schools, :map => '/get_schools' do
		@status =  JSON.parse(RestClient.get('https://www.tekala.cn/api/v1/schools'))["status"]

		if @status == 'success'
			$arr << 10
		end

		redirect_to '/test_for_student/get_class'
	end

	get :get_class, :map => '/get_class' do
		@status =  JSON.parse(RestClient.get('https://www.tekala.cn/api/v1/school/11'))["status"]

		if @status == 'success'
			$arr << 11
		end

		redirect_to '/test_for_student/get_tweets'
	end

	get :get_tweets, :map => '/get_tweets' do
		@tweets = Tweet.all(:order => :updated_at.desc, :limit =>20)
		if @tweets
			$arr << 12
		end

		redirect_to '/test_for_student/show_comments'
	end

	get :show_comments, :map => '/show_comments' do
		tweet_id = Tweet.first.id
		@comments = TweetComment.all(:tweet_id => tweet_id, :order => :created_at.asc, :limit =>20)

		if @comments
			$arr << 13
		end

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
		  	if @comment.save
			      $arr << 14
			end
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

				$arr << 15
			end
		end

		redirect_to '/test_for_student/post_like_when_not_liked'
	end

	get :post_like_when_not_liked, :map => '/post_like_when_not_liked' do
		tweet_id = Tweet.first.id
		@user = User.first(:mobile => '13094442075')

		if @user
			@like = TweetLike.first(:tweet_id => tweet_id, :user_id => @user.id)
			if @like
				@like.destroy
			end

			@like = TweetLike.new
			@like.tweet_id = tweet_id
	      		@like.user_id  = @user.id

	      		if @like.save
	      			$arr << 16
	      		end
      		end

      		redirect_to '/test_for_student/delete_like_when_liked'
	end

	get :delete_like_when_liked, :map => '/delete_like_when_liked' do
		tweet_id = Tweet.first.id
		@user = User.first(:mobile => '13094442075')

		if @user
			@like = TweetLike.first(:tweet_id => tweet_id, :user_id => @user.id)
			if @like
				if @like.destroy
					$arr << 17
				end
			else
				@like = TweetLike.new
				@like.tweet_id = tweet_id
				@like.user_id = @user.id

				if @like.save
					redirect_to '/test_for_student/delete_like_when_liked'
				end
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
		      		if @tweet.destroy
		      			$arr << 18
		      		end
			end
		end

		redirect_to '/test_for_student/delete_my_comment'
	end

	get :delete_my_comment, :map => '/delete_my_comment' do
		@user = User.first(:mobile => '13094442075')

		if @user
			@comment = TweetComment.first(:user_id => @user.id)

			if @comment.destroy
		      		$arr << 19
			end
		end

		redirect_to '/test_for_student'
	end

	post :clear_test, :map => '/clear_test' do
		$arr = []

		redirect_to '/test_for_student'
	end

end
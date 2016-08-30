# -*- encoding : utf-8 -*-
Tekala::Api.controllers :v1, :teachers do  
	register WillPaginate::Sinatra
  enable :sessions

  before do
    @user      = User.get(session[:user_id])
    @school    = @user.school

    if @user.nil?
      @subject             = params[:subject] || 2
    else
      #学员筛选 或者当前科目 对应的教练
      if params[:subject]
        @subject = params[:subject].to_i
      elsif @user.status_flag > 6 
        @subject = 3
      elsif @user.status_flag <= 6 
        @subject = 2
      end

    end
  end

  get :search, :provides => [:json] do
    @teachers     = @school.teachers.all(:name.like => "%#{params[:name]}%")
    @teachers     = @teachers.all(:status_flag => 2, :open => 1)
    @total        = @teachers.count
    @teachers     = @teachers.paginate(:page => params[:page], :per_page => 20)
    render 'v1/teachers'
  end

  get :nearby, :provides => [:json] do
    # 训练场正常使用的教练
    @teachers = @school.teachers.all(:open => 1, :status_flag => 2)

    @teachers = @teachers.all(:exam_type => [4, @user.exam_type]) if @user.exam_type.present?
    if @user.status_flag.present?
      @teachers = @teachers.all(:tech_type => [1, @subject])
    end
    @teachers = @teachers.paginate(:page => params[:page], :per_page => 20)
    @total    = @teachers.count
    render 'v1/teachers'
  end

  get :great, :provides => [:json] do
    @teachers  = @school.teachers.all(:limit => 3, :order => :weight.desc, :open => 1, :exam_type => [@user.exam_type, 3])
    @total     = @teachers.count
    render 'v1/teachers'
  end

  get :history, :provides => [:json] do 
    @teachers    = Order.all(:user_id => @user.id, :type => Order::NORMALTYPE, :status => Order::pay_or_done)
                  .teachers(:open => 1, :exam_type => [@user.exam_type, 4])
    @total       = @teachers.count
    @teachers    = @teachers.paginate(:page => params[:page], :per_page => 20)
    render 'v1/teachers'

  end

  get :train_field, :map => '/v1/teachers/:teacher_id/train_fields', :provides => [:json] do 
    teacher       = Teacher.get(params[:teacher_id])
    return {:status => :failure, :msg => '教练不存在'}.to_json if teacher.nil?
    @train_fields = teacher.train_fields
    @total        = @train_fields.count
    render 'v1/train_fields'
  end

  get :schedule, :map => "/v1/teachers/:teacher_id/schedule", :provides => [:json] do 
    @teacher = Teacher.get params[:teacher_id]
    return @teacher.nil? ? {:status => :failure, :msg => '未能找到该教练', :err_code => 1001}.to_json : @teacher.time_can_book 
  end

  get :comments, :map => 'v1/teachers/:teacher_id/comments', :provides => [:json] do 
    @comments   = TeacherComment.all(:teacher_id =>params[:teacher_id], :order => :id.desc)
    @total      = @comments.count
    @comments   = @comments.paginate(:page => params[:page], :per_page => 10)
    #加上这句会减少数据库查询次数 
    @comments.each do |comment|
      comment.user.name if !comment.user.nil?
    end
    @total = @comments.count
    #加上这句会减少数据库查询次数 
    render 'v1/teacher_comments'
  end

  post :comments, :map => 'v1/teachers/:teacher_id/comments', :provides => [:json] do
    @order = Order.get params[:order_id]
    return {:status => "failure", :msg => '该订单不存在' }.to_json          if @order.nil? 
    return {:status => "failure", :msg => '您已评论过该订单' }.to_json      if !@order.teacher_comment.nil?
    return {:status => "failure", :msg => '该订单尚未能评论' }.to_json      if !@order.can_comment

    @teacher = @order.teacher
    return {:status => :failure, :msg => "教练不存在"}.to_json if @teacher.nil?
    @comment            = TeacherComment.new
    @comment.content    = params[:content]
    @comment.order_id   = params[:order_id]
    @comment.rate       = params[:rate] if !params[:rate].nil? && !params[:rate].empty?
    @comment.user_id    = @user.id
    @comment.teacher_id = @teacher.id
    if @comment.save

      (1..9).each do |i|
        if params["photo#{i.to_s}"]
          @photo            = CommentPhoto.new 
          @photo.comment_id = @comment.id
          @photo.photo      = params["photo#{i.to_s}"]
          @photo.save
        end
      end

      #完成评论 推送给教练
      JGPush::order_comment params[:order_id]
      render 'v1/teacher_comment'
    else
      {:status => :failure, :msg => @comment.errors.full_messages.join(',') }.to_json
    end
  end


end
# -*- encoding : utf-8 -*-
Szcgs::Api.controllers :v1, :teachers do  
	register WillPaginate::Sinatra
  enable :sessions
  current_url = '/api/v1'

  default_latitude = '24.0000'
  default_longitude = '100.333'

  before do 
    @city      = params[:city] || '0755'
    @user      = User.get(session[:user_id])
    if @user.nil?
      @sql_exam_type_where = ''
      @sql_city_where      = "and city = '#{@city}'"
      @subject             = params[:subject] || 2
      @exam_type           = 'c1'
    else
      @city                = params[:city] || @user.city
      @exam_type = @user.exam_type == 2 ?  "c2" : 'c1'
      @sql_exam_type_where = "and #{@exam_type} > 0"
      @sql_city_where      = "and city = '#{@city}'"

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
    @teachers     = Teacher.all(:name.like => "%#{params[:name]}%")
    @teachers     = @teachers.all(:status_flag => 2, :open => 1)
    @total        = @teachers.count
    @teachers     = @teachers.paginate(:page => params[:page], :per_page => 20)
    render 'v1/teachers'
  end

  get :nearby, :provides => [:json] do 
    latitude  = params[:latitude]  || default_latitude
    longitude = params[:longitude] || default_longitude
    distance  = 10
    limit     = 50

    adapter = DataMapper.repository(:default).adapter 
    #查看附近教练sql语句
    # 'and subject = #{@subject}' 筛选科目三训练场 暂时未添加科三训练场 所以去除
    query = "SELECT 6371 * acos(cos(radians(#{latitude})) * cos(radians(latitude)) * cos(radians(longitude) - radians(#{longitude})) + sin(radians(#{latitude})) * sin(radians(latitude))) as distance,
               count as teacher_count, id, name, latitude, longitude, address, good_tags, bad_tags, area 
               from train_fields 
               where display = 1 and count > 0 
               and open = 1 
               
               #{@sql_city_where}
               #{@sql_exam_type_where} 
               having distance<=#{distance} 
               order by distance limit #{limit}"

    @train_fields = repository(:default).adapter.select(query)
    @total        = @train_fields ? @train_fields.size : 0 
    #如果查到的数据为空 返回全部训练场
    if @total == 0
      @train_fields = TrainField.all(:count.gt => 0, :display => true, :open => 1,
                                     :city  => @city)
      @train_fields = @train_fields.all(:order => @exam_type.to_sym.desc, 
                                        @exam_type.to_sym.gt => 0, ) if @exam_type
      #筛选科目三训练场 暂时未添加科三训练场 所以注释
      # @train_fields = @train_fields.all(:subject => @subject) if @subject

      @total        = @train_fields.count
      @train_fields = @train_fields.paginate(:page => params[:page], :per_page => 100)
      
    end

    #通过repository 获得的数据是 array 不是 Collection 所以再查一次数据库
    @train_fields = TrainField.all(:id => @train_fields.map(&:id)) 
    # 训练场正常使用的教练
    @teachers = @train_fields.teachers(:open => 1, :status_flag => 1).reverse
    @teachers = @teachers.all(:exam_type => [3, @user.exam_type]) if @user
    @teachers = @teachers.all(:subject => [0,@subject]) if @subject
    @teachers = @teachers.paginate(:page => params[:page], :per_page => 20)


    @teachers.each do |teacher|
      teacher.status_flag      = 0 if @user && @user.city == '027' && @user.type == 0
      #如果用户是c2 修改价格
      teacher.price            += 20 if @user && @user.exam_type == 2
      teacher.promo_price      += 20 if @user && @user.exam_type == 2
    end

    render 'v1/teachers'

  end 

  get :area, :provides => [:json] do 
    area_num = params[:area_num]
    city_num = params[:city_num]

    @train_fields = TrainField.all(:count.gt => 0, :display => true, :open => 1)
    @train_fields = @train_fields.all(:order => @exam_type.to_sym.desc, 
                                        @exam_type.to_sym.gt => 0) if @exam_type

    @train_fields = @train_fields.all(:city => city_num)    if !empty?(city_num)
    @train_fields = @train_fields.all(:area => area_num)    if !empty?(area_num)
    # @train_fields = @train_fields.all(:subject => @subject) if @subject
    @teachers     = @train_fields.teachers(:open => 1, :status_flag => 1).reverse
    @teachers     = @teachers.all(:exam_type => [3, @user.exam_type]) if @user
    @total        = @teachers.count
    @teachers     = @teachers.paginate(:page => params[:page], :per_page => 20)

    @teachers.each do |teacher|
      teacher.status_flag      = 0 if @user &&  @user.city == '027' && @user.type == 0
      #如果用户是c2 修改价格
      teacher.price            += 20 if @user && @user.exam_type == 2
      teacher.promo_price      += 20 if @user && @user.exam_type == 2
    end

    render 'v1/teachers'

  end


  get :great, :provides => [:json] do 
    # latitude  = params[:latitude]  || default_latitude
    # longitude = params[:longitude] || default_longitude
    # distance  = 100
    # limit     = 100
    # if !empty?(latitude) && !empty?(latitude)
    #   # and subject = #{@subject}
    #   query = "SELECT 6371 * acos(cos(radians(#{latitude})) * cos(radians(latitude)) * cos(radians(longitude) - radians(#{longitude})) + sin(radians(#{latitude})) * sin(radians(latitude))) as distance,
    #            count as teacher_count, id, name, latitude, longitude, address, good_tags, bad_tags, area
    #            from train_fields
    #            where display = 1 and count > 0
    #
    #            and open = 1 and city = '#{@user.city}'
    #            and #{@exam_type} > 0 having distance<=#{distance}
    #            order by distance limit #{limit}"
    #
    #   train_fields = DataMapper.repository(:default).adapter.select(query)
    #
    #   #通过repository 获得的数据是 array 不是 Collection 所以再查一次数据库
    #   train_fields = TrainField.all(:id => train_fields.map(&:id))
    #
    #   #筛选出训练场的教练
    #   teachers     = train_fields.teachers.all(:status_flag => 1, :open => 1,
    #                                            :exam_type => [@user.exam_type, 3]).uniq
    #   weights         =  teachers.map(&:weight)
    #   teacher_ids     =  teachers.map(&:id)
    #   teacher_hash    = {}
    #
    #   teachers.each_with_index do |teacher, index|
    #     teacher_hash.store(teacher.weight, teacher.id) if !teacher_hash[teacher.weight] || rand(1) == 1 || teacher.rate > 3.0
    #   end
    #
    #   @teacher_ids = []
    #   6.times do
    #     @teacher_ids << rand_from_weighted_hash(teacher_hash)
    #   end
    #
    #   @teachers  = Teacher.all(:id => @teacher_ids.uniq, :limit => 3, :open => 1, :exam_type => [@user.exam_type, 3], :city => @user.city)
    # else
    #   @teachers  = Teacher.all(:limit => 3, :order => :weight.desc, :open => 1, :exam_type => [@user.exam_type, 3], :city => @user.city)
    # end

    @teachers  = Teacher.all(:limit => 3, :order => :weight.desc, :open => 1, :exam_type => [@user.exam_type, 3], :city => @user.city)

    @teachers.each do |teacher|
      teacher.status_flag      = 0 if @user && @user.city == '027' && @user.type == 0
      #如果用户是c2 修改价格
      teacher.price            += 20 if @user && @user.exam_type == 2
      teacher.promo_price      += 20 if @user && @user.exam_type == 2
    end

    render 'v1/teachers'

  end

  get :history, :provides => [:json] do 
    @teachers    = Order.all(:user_id => @user.id, :type => Order::NORMALTYPE, :status => Order::pay_or_done)
                  .teachers(:open => 1, :exam_type => [@user.exam_type, 3])
    @total       = @teachers.count
    @teachers    = @teachers.paginate(:page => params[:page], :per_page => 20)
    
    @teachers.each do |teacher|
      teacher.status_flag      = 0 if @user &&  @user.city == '027' && @user.type == 0
      #如果用户是c2 修改价格
      teacher.price            += 20 if @user && @user.exam_type == 2
      teacher.promo_price      += 20 if @user && @user.exam_type == 2
    end
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
      JPush::order_comment params[:order_id]
      render 'v1/teacher_comment'
    else
      {:status => :failure, :msg => @comment.errors.full_messages.join(',') }.to_json
    end
  end


end
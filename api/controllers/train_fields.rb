# -*- encoding : utf-8 -*-
Szcgs::Api.controllers :v1, :train_fields do  
	register WillPaginate::Sinatra
  enable :sessions
  default_latitude  = '24.0000'
  default_longitude = '100.333'
  current_url       = '/api/v1'

  before do 
     @city = params[:city] || '0755'
     @user = User.get(session[:user_id])
    if @user.nil?
      @sql_exam_type_where = ''
      @sql_city_where      = "and city = '#{@city}'"
      @subject             = params[:subject] || 2 

    else
      @city                = params[:city] || @user.city
      @exam_type           = @user.exam_type == 2 ?  "c2" : 'c1'
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
    @train_fields = TrainField.all(:display => true, :open => 1, :name.like => "%#{params[:name]}%")
    @train_fields = @train_fields.all(:city_id => params[:city])       if params[:city]
    @train_fields = @train_fields.all(:subject => @subject)         if @subject
    @total        = @train_fields.count
    @train_fields = @train_fields.paginate(:page => params[:page], :per_page => 20)
    render 'v1/train_fields'
  end
  
  get :nearby, :provides => [:json] do 

  	latitude  = params[:latitude]  || default_latitude
  	longitude = params[:longitude] || default_longitude
  	distance  = 100
  	limit			= 50

    adapter = DataMapper.repository(:default).adapter 
    #查看附近教练sql语句
    query = "SELECT 6371 * acos(cos(radians(#{latitude})) * cos(radians(latitude)) * cos(radians(longitude) - radians(#{longitude})) + sin(radians(#{latitude})) * sin(radians(latitude))) as distance,
      			   count as teacher_count, id, name, c1, c2, latitude, longitude, address, good_tags, bad_tags, area 
      			   from train_fields 
      			   where display = 1 
               and count > 0 
      			   and open = 1 
               and subject = #{@subject}
               #{@sql_city_where} 
      			   #{@sql_exam_type_where}
               having distance<=#{distance} 
      			   order by distance limit #{limit}"

    @train_fields = repository(:default).adapter.select(query)

    train_field_ids        = @train_fields.map(&:id)
    train_field_distances  = @train_fields.map(&:distance)
    
    @train_fields.each_with_index do |train_field, i|
      train_field.distance = train_field_distances[i]
    end

    @total 			  = @train_fields ? @train_fields.size : 0 
    #如果查到的数据为空 返回全部训练场

    if @total == 0
    	@train_fields = TrainField.all(:count.gt => 0, :display => true, :open => 1,
    																 :city  => @city)
      @train_fields = @train_fields.all(:order => @exam_type.to_sym.desc, 
                                        @exam_type.to_sym.gt => 0) if @exam_type
      @train_fields = @train_fields.all(:subject => [0, @subject]) if @subject
    	@total        = @train_fields.count
      @train_fields = @train_fields.paginate(:page => params[:page], :per_page => 100)
    end
    render 'v1/train_fields'
  end 

  get :area, :provides => [:json] do 
  	select_area = params[:area]
    select_city = params[:city]

  	@train_fields = TrainField.all(:display => true, :open => 1)
    @train_fields = @train_fields.all(:order => @exam_type.to_sym.desc) if @exam_type

    @train_fields = @train_fields.all(:city_id => select_city)    if select_city.present?
    @train_fields = @train_fields.all(:area => select_area)    if select_area.present?
    @train_fields = @train_fields.all(:subject => [0, @subject]) if @subject

    @total = @train_fields.count
    @train_fields = @train_fields.paginate(:page => params[:page], :per_page => 20)
    render 'v1/train_fields'

  end

  get :history, :provides => [:json] do 
    @train_fields = Order.all(:user_id => @user.id, :type => Order::NORMALTYPE, :status => Order::pay_or_done)
                     .train_field(:count.gt => 0, :display => true, :open => 1)
    @total        = @train_fields.count
    @train_fields = @train_fields.paginate(:page => params[:page], :per_page => 20)
    render 'v1/train_fields'

  end

  get :teachers, :map => '/v1/train_fields/:id/teachers', :provides => [:json] do 
    train_field  = TrainField.get params[:id].to_i
    if train_field.present?
      teacher_ids = TeacherTrainField.all(:train_field_id => train_field.id)
      if teacher_ids
        @teachers    = Teacher.all(:id =>teacher_ids.aggregate(:teacher_id), :open => 1, :status_flag => 1)
        @teachers    = @teachers.all(:exam_type => [@user.exam_type, 3]) if @exam_type
        @teachers    = @teachers.all(:subject => [0, @subject]) if @subject

        @total = @teachers.count
        puts @total
        @teachers = @teachers.paginate(:page => params[:page], :per_page => 20)
        render 'v1/teachers'
      end
    else
       {:status=>:error, :msg => '训练场不存在'}.to_json
    end
  end
end
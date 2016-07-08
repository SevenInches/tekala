# -*- encoding : utf-8 -*-
Tekala::Api.controllers :v1, :schools do
  register WillPaginate::Sinatra
  enable :sessions
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

  get :schools, :map => '/v1/schools', :provides => [:json] do
    @schools = School.all(:order => :weight.desc, :is_open => 1)
    @schools = @schools.all(:city_id => params['city'] ) if params['city'].present?
    @total  = @schools.count
    @schools = @schools.paginate(:per_page => 20, :page => params[:page])
    render 'v1/schools'
  end

  get :school, :map => '/v1/school/:school_id', :provides => [:json] do
    @school = School.first(:id => params[:school_id], :is_open => 1)
    render 'v1/school'
  end

  get :teachers, :map => '/v1/teachers_via_school/:school_id', :provides => [:json] do
    @teachers = Teacher.all(:school_id => params[:school_id], :open => 1)
    @total  = @teachers.count
    render 'v1/teachers'
  end

  get :fields, :map => '/v1/fields_via_school/:school_id', :provides => [:json] do
    @train_fields = TrainField.all(:school_id => params[:school_id], :open => 1)
    @total  = @train_fields.count
    render 'v1/train_fields'
  end

  get :products, :map => '/v1/products_via_school/:school_id', :provides => [:json] do
    @product_bindings = ProductBinding.all(:school_id => params[:school_id])
    @total  = @product_bindings.count
    render 'v1/product_bindings'
  end
end
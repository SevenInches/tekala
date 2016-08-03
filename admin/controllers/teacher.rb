Tekala::Admin.controllers :teachers do

  get :index do
    @title = "Teachers"
    @teachers = Teacher.all(:order =>[:created_at.desc])
    @teachers = @teachers.all(:name.like => "%#{params[:name]}%")    if params[:name].present?
    @teachers = @teachers.all(:mobile => params[:mobile])            if params[:mobile].present?
    @teachers = @teachers.all(:school_id => params[:school_id])      if params[:school_id].present?
    @teachers = @teachers.all(:status => params[:status])            if params[:status].present?
    @teachers = @teachers.all(:exam_type => params[:exam_type])      if params[:exam_type].present?
    @teachers = @teachers.paginate(:page => params[:page], :per_page => 10)
    render 'teachers/index'
  end

  get :new do
    @teacher = Teacher.new
    render 'teachers/new'
  end

  post :create do
    @teacher = Teacher.new
    params[:teacher].each do |param|
      @teacher[param[0]] = param[1] if param[1].present?
    end

    if params[:avatar].present?
      pid = AppLaunchAd.max(:id).nil? ? 1 : AppLaunchAd.max(:id)+1
      tempfile = params[:avatar][:tempfile]
      ext = File.extname(params[:avatar][:filename])
      pic = send_picture(tempfile, ext, 'qiniu_teacher')
      avatar = upload_qiniu(pic, 'tekala_teacher_'+pid.to_s)
      @teacher['avatar'] =  CustomConfig::QINIUURL+ avatar['key'].to_s
    end

    if @teacher.save!
      flash[:success] = pat(:create_success, :model => 'Teacher')
      redirect(url(:teachers, :index))
    else
      render 'teachers/new'
    end
  end

  get :edit, :with => :id do
    @title = pat(:edit_title, :model => "teacher #{params[:id]}")
    @teacher = Teacher.get(params[:id])
    if @teacher
      render 'teachers/edit'
    else
      flash[:warning] = pat(:create_error, :model => 'Teacher', :id => "#{params[:id]}")
      halt 404
    end
  end

  put :update, :with => :id do
    @title = pat(:update_title, :model => "teacher #{params[:id]}")
    @teacher = Teacher.get(params[:id])
    if @teacher
      params[:teacher].each do |param|
        @teacher[param[0]] = param[1] if param[1].present?
      end
      if params[:avatar].present?
        pid = Teacher.max(:id).nil? ? 1 : Teacher.max(:id)+1
        tempfile = params[:avatar][:tempfile]
        ext = File.extname(params[:avatar][:filename])
        pic = send_picture(tempfile, ext, 'qiniu_teacher')
        avatar = upload_qiniu(pic, 'tekala_teacher_'+pid.to_s)
        @teacher.update( :avatar => CustomConfig::QINIUURL+ avatar['key'].to_s)
      end
      if @teacher.save
        flash[:success] = pat(:update_success, :model => 'Teacher', :id =>  "#{params[:id]}")
        redirect(url(:teachers, :index))
      else
        flash.now[:error] = pat(:update_error, :model => 'Teacher')
        render 'teachers/edit'
      end
    else
      flash[:warning] = pat(:update_warning, :model => 'Teacher', :id => "#{params[:id]}")
      halt 404
    end
  end

  delete :destroy, :with => :id do
    @title = "Teachers"
    teacher = Teacher.get(params[:id])
    if teacher
      if teacher.destroy
        flash[:success] = pat(:delete_success, :model => 'Teacher', :id => "#{params[:id]}")
      else
        flash[:error] = pat(:delete_error, :model => 'Teacher')
      end
      redirect url(:teachers, :index)
    else
      flash[:warning] = pat(:delete_warning, :model => 'Teacher', :id => "#{params[:id]}")
      halt 404
    end
  end

  delete :destroy_many do
    @title = "Teachers"
    unless params[:teacher_ids]
      flash[:error] = pat(:destroy_many_error, :model => 'Teacher')
      redirect(url(:teachers, :index))
    end
    ids = params[:teacher_ids].split(',').map(&:strip)
    teachers = Teacher.all(:id => ids)

    if teachers.destroy
      flash[:success] = pat(:destroy_many_success, :model => 'Teachers', :ids => "#{ids.to_sentence}")
    end
    redirect url(:teachers, :index)
  end

  get :export do
    @teachers  = Teacher.all(:order => :id.desc)
    @teachers  = @teachers.all(:name.like => "%#{params[:name]}%")    if params[:name].present?
    @teachers  = @teachers.all(:mobile  => params[:mobile])           if params[:mobile].present?
    @teachers  = @teachers.all(:status_flag => params[:status_flag])  if params[:status_flag].present?

    @teachers  = @teachers.all(:exam_type => params[:exam_type]) if params[:exam_type].present?
    @teachers  = @teachers.all(:school_id => params[:school_id]) if params[:school_id].present?
    @teachers  = @teachers.all(:product_id => params[:product_id]) if params[:product_id].present?

    book = Spreadsheet::Workbook.new
    sheet = book.create_worksheet
    sheet[0,0]    = "#id"
    sheet[0,1]    = "教练"
    sheet[0,2]    = "手机号"
    sheet[0,3]    = "状态"
    sheet[0,4]    = "驾考类型"
    sheet[0,5]    = "驾校"
    sheet[0,6]    = "教学科目"
    sheet[0,7]    = "创建时间"
    format = Spreadsheet::Format.new :color => :blue,
                                     :weight => :bold,
                                     :size => 15
    sheet.row(0).default_format = format

    @teachers.each_with_index do |teacher,index|
      sheet[index+1,0]    = teacher.id
      sheet[index+1,1]    = teacher.name
      sheet[index+1,2]    = teacher.mobile
      sheet[index+1,3]    = teacher.status_word
      sheet[index+1,4]    = teacher.exam_type_word
      sheet[index+1,5]    = teacher.school.present? ? teacher.school.name : ''
      sheet[index+1,6]    = teacher.tech_type_word
      sheet[index+1,7]    = teacher.created_at.present? ? teacher.created_at.strftime('%m月%d日 %H:%M') : ''
    end

    output_file_name = "teacher_#{Time.now.to_i}.xls"
    book.write "public/uploads/#{output_file_name}"

    redirect "/uploads/#{output_file_name}"
  end

  post :inport do
    if params['file'].present?
      excel_name   = 'public/uploads/excels/'+params['file'][:filename]

      File.open(excel_name, "w") do |f|
        f.write(params['file'][:tempfile].read.force_encoding('utf-8'))
      end

      xlsx  = Roo::Excelx.new(excel_name)
      sheet = xlsx.sheet('Worksheet1')

      puts sheet.count
      #遍历excel列
      (2..(sheet.count)).each do |row|
        name          = sheet.cell("B", row)
        mobile        = sheet.cell("C", row).to_i
        status        = sheet.cell("D", row)
        exam_type     = sheet.cell("E", row)
        school        = sheet.cell("F", row)
        tech_type     = sheet.cell("G", row)

        #创建一个学员
        teacher = Teacher.first(:mobile => mobile)
        if !teacher.present?
          teacher = Teacher.new(:mobile => mobile)
        end
        teacher.name        = name
        teacher.exam_type   = Teacher.exam_type_reverse(exam_type)
        teacher.status      = Teacher.status_reverse(status)
        teacher.school_id   = School.first_school_id(school)
        teacher.tech_type   = Teacher.tech_type_reverse(tech_type)
        teacher.password    = '123456'
        if teacher.save
          flash[:success] = pat(:inport_success, :model => 'Teacher')
        end
      end
    end
    redirect(url(:teachers, :index))
  end


end

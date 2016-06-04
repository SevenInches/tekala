# -*- encoding : utf-8 -*-
class ExamSpider 
  #请求驾考列表
  def self.spider_form(page)
    @curl     = Curl::Easy.new
    @curl.url = CustomConfig::EXAMLISTMAIN + CustomConfig::EXAMLISTPAGE
    @curl.http_get
    cookie    = /^Set-Cookie:\s*([^;]*)/mi.match(@curl.header_str)

    #请求参数
    params = {
      :loginVerifyCode => getSecondSubCode(cookie[1]),
      :pageNum => page,
      :djZhouQi => "2015-11-30",
      :pageSize => 100
    }

    @curl.http_post @curl.url, params.map{ |k,v| Curl::PostField.content k, v }
    doc = Nokogiri::HTML(@curl.body_str, nil, "UTF-8")

    doc.xpath("//table[@id='ejiaA1']/*[not (@class='table_t')]").each do |tr|
      if custom_td = tr.css('td')
        exam               = SecondSubList.new
        exam.num           = str_format custom_td[1].content
        exam.id_card       = str_format custom_td[2].content
        exam.name          = str_format custom_td[3].content
        exam.drive_school  = str_format custom_td[4].content
        exam.register_time = str_format custom_td[5].content
        exam.register_cycle= str_format custom_td[6].content
        exam.allow_exam    = str_format custom_td[7].content
        exam.wait_value    = str_format custom_td[8].content
        exam.count         = str_format custom_td[9].content
        exam.exam_type     = str_format custom_td[10].content
        exam.section_name  = str_format custom_td[11].content
        exam.save

      end
    end
  end

  def self.spider_success(page)
    @curl  = Curl::Easy.new
    @curl.url = 'http://app.stc.gov.cn:8090/kszzyy/reportout_getPdListNew.action'
    @curl.http_get
    cookie    = /^Set-Cookie:\s*([^;]*)/mi.match(@curl.header_str)    
    params = {
      :loginVerifyCode => getSecondSubCode(cookie[1]),
      :pageNum => page,
      :examNum => '科目二',
      :schoolName => '散学',
      :djZhouQi => "2015-11-30",
      :pageSize => 100
    }
    
    @curl.http_post @curl.url,  params.map{ |k,v| Curl::PostField.content k, v }
    

    doc = Nokogiri::HTML(@curl.body_str, nil, "UTF-8")
    
    
        doc.xpath("//table[@id='ejiaA1']/*[not (@class='table_t')]").each do |tr|
          if custom_td = tr.css('td')
            exam = ExamList.first_or_create(:num => str_format(custom_td[3].content))
            
            exam.exam_time    = str_format custom_td[1].content
            # exam.num          = str_format custom_td[3].content
            exam.id_card      = str_format custom_td[4].content
            exam.section      = str_format custom_td[2].content
            exam.name         = str_format custom_td[5].content
            exam.drive_school = str_format custom_td[6].content
            exam.register     = str_format custom_td[7].content
            exam.allow_exam   = str_format custom_td[9].content
            exam.wait_value   = str_format custom_td[10].content
            exam.exam_count   = str_format custom_td[11].content
            exam.car_type     = str_format custom_td[12].content
            exam.section_name = str_format custom_td[13].content
            # section_name      =  str_format(custom_td[13].content).force_encoding('utf-8')
            # exam.section_name = section_name
            puts exam.save

          end
        end
  end

  #测算时间
  def self.calculate_time(name, id_card, mobile, section)
    has_calculate = CalculateList.first(:id_card => id_card, :section => section)
    if !has_calculate.nil?
      if !has_calculate.start_date.nil?
        return {:id => has_calculate.id, :status => 'success'}.to_json
      else
        return {:status => 'failure', :msg => '您未加入排队'}.to_json
      end
    end

    @record = SecondSubList.first(:name => name.gsub(name[1..10], "*"), :id_card => id_card.gsub(id_card[6..13], "*"*8))
    if @record.nil?
      CalculateList.create(:name => name, :id_card => id_card, :mobile => mobile, :section => section)      
      return {:status => 'failure', :msg => '您未加入排队'}.to_json
    end
    exam_type = @record.exam_type
    drive_school = @record.drive_school
    section_name = @record.section_name
    @lists = SecondSubList.all(:exam_type => exam_type, :drive_school => '散学', :section_name.like => "%#{section}%")
    count = 1

    @lists.each do |data|
      if data.id == @record.id
        break
      else
        count += 1
      end
    end

    case section_name
    when /科目一/
      index_gt = 115
      index_lt = 115 * 0.95
    when /科目二/ || /5项/
      if exam_type == 'C1'
        index_gt = 212 * 0.80
        index_lt = 212 * 0.60
      end
      if exam_type == 'C2'
        index_gt = 38 * 0.90
        index_lt = 38 * 0.80
      end
    when /科目三文明驾驶/
      puts '文明考试不做统计'
    when /科目三/
      if exam_type == 'C1'
        index_gt = 104 * 0.90
        index_lt = 104 * 0.70
      end
      if exam_type == 'C2'
        index_gt = 34 * 0.90
        index_lt = 34 * 0.80
      end
    end
    start_at   = count/index_gt + 3
    end_at     = count/index_lt + 3
    start_date = "2015-11-30".to_date + start_at.weeks
    end_date   = "2015-11-30".to_date + end_at.weeks
    @result = CalculateList.create(:name => name, :id_card => id_card, :start_date => start_date, :end_date => end_date, :exam_type => exam_type, :mobile => mobile, :section => section)
    
    return {:id => @result.id, :status => 'success'}.to_json
  end
end


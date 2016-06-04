# -*- encoding : utf-8 -*-
#监测当前是否已经登录
def checkLogin 
  puts "step 1 监测是否登录"
  @curl     = Curl::Easy.new

  #异常处理
  @setting_app_8090  = YAML.load_file(Padrino.root('lib/setting_app_8090.yml'))
  @setting_cgs1_8086 = YAML.load_file(Padrino.root('lib/setting_cgs1_8086.yml'))
  @setting_cgs1_8088 = YAML.load_file(Padrino.root('lib/setting_cgs1_8088.yml'))
  @setting = [@setting_cgs1_8086, @setting_cgs1_8088, @setting_app_8090].shuffle
  
  retries = 0
  begin 
    @curl.url = @setting[retries]["INFO"]
    @curl.http_get 

  rescue => err 
    puts err 
    retries = retries+1 
    retry unless retries>2
  ensure
    #redis 保存 当前可用的域名
    CustomRedis.new(@setting[retries])
    puts CustomRedis::setting['EXAM3DESTINECANCEL']
  end

  doc       = Nokogiri::HTML(@curl.body_str, nil, "UTF-8")
  @content  = doc.at_css('//script')
  @content  =~ /会话失效/

  "如果还未登录"
  if @content 
    
    @msg  = 'int'
    while @msg =~ /登录异常/ || @msg =~ /验证码错误/ || @msg =='int' 
      if @msg =~ /登录异常/
        checkLogin
        return 
      end
      # return {:status => :failure, :msg=> '登录异常，稍候重试' }.to_json if @msg =~ /登录异常/
      @result = login @u.id_card, @u.book_password
      @msg    = @result[:error_msg]
    end
    @u.cookie = @result[:cookie]
    @u.save
    @login = true
  end
  puts "======判断 timeline login"
  puts @u.timeline.nil?
  puts @login
  puts "=======判断 time login"
  if @u.timeline.nil? || @u.timeline == '[]' || @login
      '获取个人考试历史 start'
      @curl.headers["Cookie"] = @u.cookie
      puts @curl.url = CustomRedis::setting['INFO']
      @curl.http_get 
      puts doc  = Nokogiri::HTML(@curl.body_str, nil, "UTF-8")
      timeline = []

      doc.xpath('//table[2]/tr').each do |tr|
        hash = {}

        if tr.css('td')[2] && !tr.css('td')[2].content.empty?
          hash['num']    =  str_format(tr.css('td')[0].content) if tr.css('td')[0]
          hash['event']  =  str_format(tr.css('td')[1].content) if tr.css('td')[1]
          hash['time']   =  str_format(tr.css('td')[2].content) if tr.css('td')[2]
          hash['detail'] =  str_format(tr.css('td')[3].content) if tr.css('td')[3]

          '根据个人流水更新用户的状态 start'
          
          @u.status_flag = 12 if  hash['event'] == '科目一预约' 
          @u.status_flag = 13 if  hash['event'] == '科目一考试' && hash['detail'] =~ /合格/
          @u.status_flag = 11 if  hash['event'] == '科目一考试' && hash['detail'] =~ /不合格/

          @u.status_flag = 22 if  hash['event'] == '科目二预约' 
          @u.status_flag = 23 if  hash['event'] == '科目二考试' && hash['detail'] =~ /合格/
          @u.status_flag = 21 if  hash['event'] == '科目二考试' && hash['detail'] =~ /不合格/

          @u.status_flag = 32 if  hash['event'] == '科目三预约' 
          @u.status_flag = 33 if  hash['event'] == '科目三考试' && hash['detail'] =~ /合格/
          @u.status_flag = 31 if  hash['event'] == '科目三考试' && hash['detail'] =~ /不合格/

          @u.status_flag = 42 if  hash['event'] == '科目三文明预约' 
          @u.status_flag = 43 if  hash['event'] == '科目三文明考试' && hash['detail'] =~ /合格/
          @u.status_flag = 41 if  hash['event'] == '科目三文明考试' && hash['detail'] =~ /不合格/

          '根据个人流水更新用户的状态 end'
          puts "=====个人流水 hash="
          puts hash
          puts "=====个人流水 hash="
          timeline << hash
        end
      end
      puts "========"
      puts JSON.parse(timeline.to_json)
      puts "============"
      @u.timeline = timeline.to_json

      @u.save

      '获取个人考试历史 end'
  end

  return @msg
end 

def login id_card, password

  @curl = Curl::Easy.new
  @curl.url  = CustomRedis::setting['LOGINURL']
  @curl.http_get

  '获取登录页面cookie'
  cookie       = /^Set-Cookie:\s*([^;]*)/mi.match(@curl.header_str)
  @cookie      = cookie[1]

  '用户登录数据'
  user_data = {
    :sfzhm           => id_card ||='',
    :lsh             => '',
    :password        => password||='',
    :loginVerifyCode => getCode(@cookie)
  }

  puts '====='*10
  puts user_data
  puts '====='*10

  "header参数"
  @curl.headers["Cookie"]          = @cookie
  @curl.headers["Pragma"]          = 'no-cache'
  @curl.headers["Origin"]          = 'http://cgs1.stc.gov.cn:8088'
  @curl.headers["Accept-Encoding"] = 'gzip, deflate'
  @curl.headers["Accept-Language"] = 'zh-CN,zh;q=0.8,en;q=0.6,tr;q=0.4,zh-TW;q=0.2'
  @curl.headers["User-Agent"]      = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2272.118 Safari/537.36'
  @curl.headers["Content-Type"]    = 'application/x-www-form-urlencoded'
  @curl.headers["Accept"]          = 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8'
  @curl.headers["Cache-Control"]   = 'no-cache'
  @curl.headers["Referer"]         = CustomRedis::setting['LOGINURL']
  @curl.headers["Connection"]      = 'keep-alive'

  @curl.http_post @login_page, user_data.map{ |k,v| Curl::PostField.content k, v }
  #获取输出信息
  doc     = Nokogiri::HTML(@curl.body_str)
  element = doc.at_css('.actionMessage')
  #返回错误提示
  puts element
  error_msg  = ''
  puts error_msg  = element.content if element


  {:error_msg => error_msg, :cookie => @cookie }
end

def getCode cookie 
    c = Curl::Easy.new
    cod_name = 'login-code/'+(Time.now.to_i).to_s + Random.rand(999).to_s + '.jpg'
    c.url = CustomRedis::setting['LOGINCODE']
    c.headers["Referer"]         = CustomRedis::setting['LOGINURL']
    c.headers["Cookie"] = cookie
    
    puts c.headers
    c.http_get
    puts "==="*15
    puts c.header_str
    puts "==="*15
    #保存图片
    open(cod_name,"wb"){|f|f.write(c.body_str)}
    #识别并返回字符串
    img = MiniMagick::Image.new(cod_name) 
    image = RTesseract.new(img.path)
    puts "images = " + image.to_s.sub(/\s+$/, "")

    return image.to_s.sub(/\s+$/, "")
end

def str_format str
  return str.gsub("\r", '').gsub("\t", '').gsub("\n", '')
  
end

def current_page?(paths)
  if paths.class == String
    return request.path_info.include? paths
  end
  
  paths.each do |path|
    return true if request.path_info.include? path
  end
  false
end

def active_page?(path='')
  request.path_info == '/' + path
end


#发邮件给用户 params emails[array] template[string] sub[hash]填充参数
def send_email(emails, template, sub = {})
    
    
    vars = JSON.dump({"to" => emails , "sub" => sub })

    response = RestClient.post "http://sendcloud.sohu.com/webapi/mail.send_template.json",
    :api_user => "mmxueche_service" , # 使用api_user和api_key进行验证
    :api_key => "ZfJF6wvqa3zKkfgN",
    :from => "service@yommxc.com", # 发信人，用正确邮件地址替代
    :fromname => "萌萌学车",
    :substitution_vars => vars,
    :template_invoke_name => template,
    :subject => "萌萌学车介绍及报考攻略",
    :resp_email_id => 'true'
    return response
end


#创建dir
def my_mkdir(dirPath)
  unless File.exist?(dirPath)
    my_mkdir(dirPath[0, dirPath.rindex('/')]) if dirPath.rindex('/')
    Dir::mkdir dirPath
  end
  return dirPath
end

#保存图片
def save_image(save_path, pic)
  require 'net/http'
  # screen = HTTP.get(pic).to_s
  screen = open(pic) { |f| f.read }
  
  img_file = File.new(save_path,"wb")
  img_file.write screen
  img_file.close
end

#根据权重获得随机数
def rand_from_weighted_hash hash
  total_weight = hash.inject(0) { |sum,(weight,v)| sum+weight }
  running_weight = 0
  n = rand*total_weight
  hash.each do |weight,v|
    return v if n > running_weight && n <= running_weight+weight
    running_weight += weight
  end
end

#获取散学科目二报名未成功列表的验证码
def getSecondSubCode(cookie)
  c                   = Curl::Easy.new
  cod_name            = 'login-code/'+(Time.now.to_i).to_s + Random.rand(999).to_s + '.jpg'
  c.url               = CustomConfig::EXAMLISTMAIN + CustomConfig::VERIFYCODE
  c.headers["Cookie"] = cookie
  c.http_get
  #保存图片至本地
  open(cod_name,"wb"){|f|f.write(c.body_str)}
  #识别并返回字符串
  img                 = MiniMagick::Image.new(cod_name) 
  image               = RTesseract.new(img.path)
  return image.to_s.sub(/\s+$/, "")
end
#获取散学报名成功列表的验证码
def getSecondSubCode(cookie)
  c                   = Curl::Easy.new
  cod_name            = 'login-code/'+(Time.now.to_i).to_s + Random.rand(999).to_s + '.jpg'
  c.url               = 'http://app.stc.gov.cn:8090/kszzyy/verifyCode.action'
  c.headers["Cookie"] = cookie
  c.http_get
  #保存图片至本地
  open(cod_name,"wb"){|f|f.write(c.body_str)}
  #识别并返回字符串
  img                 = MiniMagick::Image.new(cod_name) 
  image               = RTesseract.new(img.path)
  return image.to_s.sub(/\s+$/, "")
end

def exam_type(examination)
  case examination
  when /科目一/
    return '科目一'
  when /科目二/ 
    return '科目二'
  when /5项/
    return '科目二'
  when /安全文明/
    return '安全文明'
  when /科目三/
    return '科目三'
  end
  
end


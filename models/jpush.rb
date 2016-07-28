#  ==================================================
#  file:    jpush.rb
#  desc:    极光推送
#
#  Created by 特快拉 on 2016-07-27.
#  Copyright (c) 2016年 特快拉. All rights reserved.
#  ==================================================      
    
# 极光推送
class JPush
  #from app@mmxueche.com 管理版
  #pwd  pVh7tnAViy6F

  #学员版本
  KEY = "164d07f0e6d086a219295841"
  SEC = "07850c205a6b60c8ab7a0543"

  #教练版
  TEACHERKEY = "666bfd915856f8db083da084"
  TEACHERSEC = "db8e69cb1c8a6458d91c6f02"

  #驾校版
  SCHOOLKEY = "53b5400b0cddd0a1082b4c7c"
  SCHOOLSEC = "ece89cbac8c32d2e7697737f"

  #门店版
  SHOPKEY = "9a33f3b03cdd83373b357414"
  SHOPSEC = "9af36422b37bc459adc6fe2c"

  #代理版
  CHANNELKEY = "56c1a0a82735f9baea8bb629"
  CHANNELSEC = "25d896b5d83189aea9c3d042"

  APNS_PRODUCTION = "true"

  URL = URI('https://api.jpush.cn/v3/push')

  #推送给管理app
  def self.send message="有新教练加入啦!"

    Net::HTTP.start(URL.host, URL.port,:use_ssl => URL.scheme == 'https') do |http|
      @count = Teacher.count
      req=Net::HTTP::Post.new(URL.path)
      req.basic_auth KEY,SEC
      jpush =[]
      jpush << 'platform=all'
      jpush << 'audience=all'

        jpush << 'notification={

            "ios":{
                   "alert":"'+message+'",
                   "content-available":1,
                   "extras":{"type": "teacher", "msg": "'+message+'", "count": "'+@count.to_s+'" }
                     }
                  }'
        jpush << 'options={"time_to_live":60,"apns_production" : '+APNS_PRODUCTION+'}'
        req.body = jpush.join("&")
        resp=http.request(req)
        p resp.body
    end
  end

  def self.send_one(account, msg, type, data) 
    Net::HTTP.start(URL.host, URL.port,:use_ssl => URL.scheme == 'https') do |http|
        req=Net::HTTP::Post.new(URL.path)
        req.basic_auth KEY,SEC
        jpush =[]
        jpush << 'platform=all'
        jpush << 'audience={"alias" : ["'+account.to_s+'"]}'

        jpush << 'notification={
            "alert":"'+msg+'",
            "android" : {
                   "extras":{"type"  : "'+type+'", "id" : "'+data+'"
                   }
                },
            "ios":{
                   "content-available":1,
                   "extras":{"type"  : "'+type+'", "id" : "'+data+'"
                        }
                     }
                  }'
        jpush << 'options={"time_to_live":60,"apns_production" : '+APNS_PRODUCTION+'}'
        req.body = jpush.join("&")
        resp=http.request(req)
        
    end

  end  

  def self.send_phone(phone, msg)
    Net::HTTP.start(URL.host, URL.port,:use_ssl => URL.scheme == 'https') do |http|
        req=Net::HTTP::Post.new(URL.path)
        req.basic_auth KEY,SEC
        jpush =[]
        jpush << 'platform=all'
        jpush << 'audience={"alias" : ["'+phone.to_s+'"]}'

        jpush << 'notification={
            "alert":"'+msg+'",
            "ios":{
                 "content-available":1,
                 "extras":{"type": "message", "msg": "'+msg+'" }
                   }
                }'
        jpush << 'options={"time_to_live":60,"apns_production" : '+APNS_PRODUCTION+'}'
        req.body = jpush.join("&")
        resp=http.request(req)
        
    end
  end

  def self.send_version(version, msg)
    Net::HTTP.start(URL.host, URL.port,:use_ssl => URL.scheme == 'https') do |http|
        req=Net::HTTP::Post.new(URL.path)
        req.basic_auth KEY,SEC
        jpush =[]
        jpush << 'platform=all'
        jpush << 'audience={"tag" : ["'+version.to_s+'"]}'

        jpush << 'notification={
            "alert":"'+msg+'",
            "ios":{
                 "content-available":1,
                 "extras":{"type": "message", "msg": "'+msg+'" }
                   }
                }'

        jpush << 'message={ "msg_content" : "'+msg+'", "title": "'+msg+'", "extras": {"type": "message", "msg": "'+msg+'" }}'

        jpush << 'options={"time_to_live":60,"apns_production" : '+APNS_PRODUCTION+'}'
        req.body = jpush.join("&")
        resp = http.request(req)
    end
  end

  def self.send_message(tags, msg, edition)
    key, sec= convert_edition(edition)
    Net::HTTP.start(URL.host, URL.port,:use_ssl => URL.scheme == 'https') do |http|
      req=Net::HTTP::Post.new(URL.path)
      req.basic_auth key, sec
      jpush =[]
      jpush << 'platform=all'
      jpush << 'audience={"tag_and" : '+tags.to_s+'}'
      jpush << 'notification={
            "alert":"'+msg+'",
            "ios":{
                 "content-available":1,
                 "extras":{"type": "message", "msg": "'+msg+'" }
                   }
                }'
      jpush << 'message={ "msg_content" : "'+msg+'", "content_type": "text", "title": "消息推送" }'
      jpush << 'options={"time_to_live":60,"apns_production" : '+APNS_PRODUCTION+'}'
      req.body = jpush.join("&")
      resp=http.request(req)
    end
  end

  #新预约通知 您有一个新订单，立即处理
  def self.order_confirm order_id
    order = Order.get order_id

    current_alias = "teacher_"+order.teacher_id.to_s

    #发短信，前期兼容iOS 收不到推送
    #sms_content = "您有一个新订单，打开特快拉教练端接单吧！下载地址：http://fir.im/mmteacher，登录账号为手机号码，默认密码为：123456"
    sms_content = "您有一个新订单，打开特快拉教练端接单吧"
    sms = Sms.new(:content => sms_content, :teacher_mobile => order.teacher.mobile)
    sms.order_confirm
    
    Net::HTTP.start(URL.host, URL.port,:use_ssl => URL.scheme == 'https') do |http|
        req=Net::HTTP::Post.new(URL.path)
        req.basic_auth TEACHERKEY,TEACHERSEC
        jpush =[]
        jpush << 'platform=all'
        jpush << 'audience={"alias" : ["'+current_alias+'"]}'

        jpush << 'notification={
            "ios":{
                 "alert":"您有一个新订单",
                 "content-available":1,
                 "extras":{"type": "order_confirm", "msg": "您有一个新订单", "order_id": "'+order.id.to_s+'" }
                   }
                }'

        
        jpush << 'message={ "msg_content" : "您有一个新订单", "title": "您有一个新订单", "extras": {"type": "order_confirm", "msg": "您有一个新订单", "order_id": "'+order_id.to_s+'" }

        }'

        jpush << 'options={"time_to_live":60,"apns_production" : '+APNS_PRODUCTION+'}'
        req.body = jpush.join("&")
        resp=http.request(req)

        TeacherNotice.create(:teacher_id => order.teacher_id, :type => 'order_confirm', :note => '您有一个新订单', :value => order.id )
        
    end

  end #order_confirm


  #订单开始前1个小时推送 您的学车预约即将开始，立即查看
  def self.order_remind  order_id 
    order = Order.get order_id
    return false if order.nil?

    username   = order.user.name
    time       = order.book_time.strftime('%H:%M')
    trainfield = order.train_field.name

    current_alias = "user_"+order.user_id.to_s
    #提醒学员
    Net::HTTP.start(URL.host, URL.port,:use_ssl => URL.scheme == 'https') do |http|
        req=Net::HTTP::Post.new(URL.path)
        req.basic_auth KEY,SEC
        jpush =[]
        jpush << 'platform=all'
        jpush << 'audience={"alias" : ["'+current_alias+'"]}'

        jpush << 'notification={
            "ios":{
                 "alert":"1个小时后教练教你学车带你飞，现在你准备好了吗？",
                 "content-available":1,
                 "extras":{"type": "order_remind", "msg": "1个小时后教练教你学车带你飞，现在你准备好了吗？", "order_id": "'+order.id.to_s+'" }
                   }
                }'

        
        jpush << 'message={ "msg_content" : "1个小时后教练教你学车带你飞，现在你准备好了吗？", "title": "1个小时后教练教你学车带你飞，现在你准备好了吗？", "extras": {"type": "order_remind", "msg": "您的学车预约一小时后开始，立即查看", "order_id": "'+order_id.to_s+'" }

        }'

        jpush << 'options={"time_to_live":60,"apns_production" : '+APNS_PRODUCTION+'}'
        req.body = jpush.join("&")
        resp=http.request(req)
    end

    current_alias = "teacher_"+order.teacher_id.to_s

    #提醒教练
    Net::HTTP.start(URL.host, URL.port,:use_ssl => URL.scheme == 'https') do |http|
        req=Net::HTTP::Post.new(URL.path)
        req.basic_auth TEACHERKEY,TEACHERSEC
        jpush =[]
        jpush << 'platform=all'
        jpush << 'audience={"alias" : ["'+current_alias+'"]}'

        jpush << 'notification={
            "ios":{
                 "alert":"行程提醒：学员'+username+' '+time+' 在'+trainfield+'练车",
                 "content-available":1,
                 "extras":{"type": "order_remind", "msg": "行程提醒：学员'+username+' '+time+' 在'+trainfield+'练车", "order_id": "'+order.id.to_s+'" }
                   }
                }'

        
        jpush << 'message={ "msg_content" : "行程提醒：学员'+username+' '+time+' 在'+trainfield+'练车", "title": "行程提醒：学员'+username+' '+time+' 在'+trainfield+'练车", "extras": {"type": "order_remind", "msg": "行程提醒：学员'+username+' '+time+' 在'+trainfield+'练车", "order_id": "'+order_id.to_s+'" }

        }'

        jpush << 'options={"time_to_live":60,"apns_production" : '+APNS_PRODUCTION+'}'
        req.body = jpush.join("&")
        resp=http.request(req)

        TeacherNotice.create(:teacher_id => order.teacher_id, :type => 'order_remind', :note => "行程提醒：学员#{username} #{time} 在 #{trainfield} 练车", :value => order.id )

    end


  end #order_remind

  #订单被学员取消了
  def self.order_cancel order_id 
    order = Order.get order_id
    if order.order_confirm && order.order_confirm.status == 2

      current_alias = "user_"+order.user_id.to_s
      #如果是教练取消了订单 推送给学员
      Net::HTTP.start(URL.host, URL.port,:use_ssl => URL.scheme == 'https') do |http|
          req=Net::HTTP::Post.new(URL.path)
          req.basic_auth KEY,SEC
          jpush =[]
          jpush << 'platform=all'
          jpush << 'audience={"alias" : ["'+current_alias+'"]}'

          jpush << 'notification={
              "ios":{
                   "alert":"啊哦～教练太忙接不过来单，预约其他时间或者换个教练试试？",
                   "content-available":1,
                   "extras":{"type": "order_cancel", "msg": "啊哦～教练太忙接不过来单，预约其他时间或者换个教练试试？", "order_id": "'+order.id.to_s+'" }
                     }
                  }'

          
          jpush << 'message={ "msg_content" : "啊哦～教练太忙接不过来单，预约其他时间或者换个教练试试？", "title": "啊哦～教练太忙接不过来单，预约其他时间或者换个教练试试？", "extras": {"type": "order_cancel", "msg": "啊哦～教练太忙接不过来单，预约其他时间或者换个教练试试？", "order_id": "'+order_id.to_s+'" }

          }'

          jpush << 'options={"time_to_live":60,"apns_production" : '+APNS_PRODUCTION+'}'
          req.body = jpush.join("&")
          resp=http.request(req)
          puts resp
      end

    else
      current_alias = "teacher_"+order.teacher_id.to_s
      #学员取消预订 则推送给教练
      Net::HTTP.start(URL.host, URL.port,:use_ssl => URL.scheme == 'https') do |http|
          req=Net::HTTP::Post.new(URL.path)
          req.basic_auth TEACHERKEY,TEACHERSEC
          jpush =[]
          jpush << 'platform=all'
          jpush << 'audience={"alias" : ["'+current_alias+'"]}'

          jpush << 'notification={
              "ios":{
                   "alert":"学员取消了订单，立即查看",
                   "content-available":1,
                   "extras":{"type": "order_cancel", "msg": "学员取消了订单，立即查看", "order_id": "'+order.id.to_s+'" }
                     }
                  }'

          
          jpush << 'message={ "msg_content" : "学员取消了订单，立即查看", "title": "学员取消了订单，立即查看", "extras": {"type": "order_cancel", "msg": "学员取消了订单，立即查看", "order_id": "'+order_id.to_s+'" }

          }'

          jpush << 'options={"time_to_live":60,"apns_production" : '+APNS_PRODUCTION+'}'
          req.body = jpush.join("&")
          resp=http.request(req)
          
          TeacherNotice.create(:teacher_id => order.teacher_id, :type => 'order_cancel', :note => "学员取消了订单，立即查看", :value => order.id )

      end


    end

  end #order_cancel

  #学员完成评价 推送给教练
  def self.order_comment order_id 
    order = Order.get order_id

    current_alias = "teacher_"+order.teacher_id.to_s

    Net::HTTP.start(URL.host, URL.port,:use_ssl => URL.scheme == 'https') do |http|
        req=Net::HTTP::Post.new(URL.path)
        req.basic_auth TEACHERKEY,TEACHERSEC
        jpush =[]
        jpush << 'platform=all'
        jpush << 'audience={"alias" : ["'+current_alias+'"]}'

        jpush << 'notification={
            "ios":{
                 "alert":"学员评价了您，戳进来看看",
                 "content-available":1,
                 "extras":{"type": "order_comment", "msg": "学员评价了您，戳进来看看", "order_id": "'+order.id.to_s+'" }
                   }
                }'

        
        jpush << 'message={ "msg_content" : "学员评价了您，戳进来看看", "title": "学员评价了您，戳进来看看", "extras": {"type": "order_comment", "msg": "学员评价了您，戳进来看看", "order_id": "'+order_id.to_s+'" }

        }'

        jpush << 'options={"time_to_live":60,"apns_production" : '+APNS_PRODUCTION+'}'
        req.body = jpush.join("&")
        resp=http.request(req)
        
        TeacherNotice.create(:teacher_id => order.teacher_id, :type => 'order_comment', :note => "学员评价了您，戳进来看看", :value => order.id )

        
    end

  end #order_comment

  def self.tweet_comment(tweet_id, from_user_id, reply_user_id=nil, content='')
    tweet = Tweet.get tweet_id
    return false if tweet.nil?

    #如果评论的用户不是推主 则推送评论通知
    if from_user_id != tweet.user_id

      current_alias = "user_"+tweet.user_id.to_s

      Net::HTTP.start(URL.host, URL.port,:use_ssl => URL.scheme == 'https') do |http|
        req=Net::HTTP::Post.new(URL.path)
        req.basic_auth KEY,SEC
        jpush =[]
        jpush << 'platform=all'
        jpush << 'audience={"alias" : ["'+current_alias+'"]}'

        jpush << 'notification={
            "ios":{
                 "alert":"你收到了新的评论，戳进来看看",
                 "content-available":1,
                 "extras":{"type": "tweet_comment", "msg": "你收到了新的评论，戳进来看看", "tweet_id": "'+tweet.id.to_s+'" }
                   }
                }'

        jpush << 'message={ "msg_content" : "你收到了新的评论，戳进来看看", "title": "你收到了新的评论，戳进来看看", "extras": {"type": "tweet_comment", "msg": "你收到了新的评论，戳进来看看", "tweet_id": "'+tweet.id.to_s+'" }

        }'

        jpush << 'options={"time_to_live":60,"apns_production" : '+APNS_PRODUCTION+'}'
        req.body = jpush.join("&")
        resp=http.request(req)
        puts resp
        #添加消息通知
        message = Message.create(:type => 'tweet_comment', :user_id => tweet.user_id, :from_user_id => from_user_id, :tweet_id => tweet.id, :status => 0, :content => content)
      end

    end 

    #如果回复的用户不是推主 则推送评论通知
    if reply_user_id && reply_user_id.to_i != tweet.user_id

      current_alias = "user_"+reply_user_id.to_s

      Net::HTTP.start(URL.host, URL.port,:use_ssl => URL.scheme == 'https') do |http|
        req=Net::HTTP::Post.new(URL.path)
        req.basic_auth KEY,SEC
        jpush =[]
        jpush << 'platform=all'
        jpush << 'audience={"alias" : ["'+current_alias+'"]}'

        jpush << 'notification={
            "ios":{
                 "alert":"你收到了新的回复，戳进来看看",
                 "content-available":1,
                 "extras":{"type": "tweet_reply", "msg": "你收到了新的回复，戳进来看看", "tweet_id": "'+tweet.id.to_s+'" }
                   }
                }'

        
        jpush << 'message={ "msg_content" : "你收到了新的回复，戳进来看看", "title": "你收到了新的回复，戳进来看看", "extras": {"type": "tweet_reply", "msg": "你收到了新的回复，戳进来看看", "tweet_id": "'+tweet.id.to_s+'" }

        }'

        jpush << 'options={"time_to_live":60,"apns_production" : '+APNS_PRODUCTION+'}'
        req.body = jpush.join("&")
        resp=http.request(req)
        puts resp
        #添加消息通知
        message = Message.create(:type => 'tweet_reply', :user_id => reply_user_id, :from_user_id => from_user_id, :reply_user_id => reply_user_id, :tweet_id => tweet.id, :status => 0, :content => content)
      end

    end

  end #tweet_comment end

  def self.tweet_like(tweet_id, from_user_id)
    tweet = Tweet.get tweet_id
    return false if tweet.nil?

    if from_user_id != tweet.user_id

      current_alias = "user_"+tweet.user_id.to_s

      Net::HTTP.start(URL.host, URL.port,:use_ssl => URL.scheme == 'https') do |http|
        req=Net::HTTP::Post.new(URL.path)
        req.basic_auth KEY,SEC
        jpush =[]
        jpush << 'platform=all'
        jpush << 'audience={"alias" : ["'+current_alias+'"]}'

        jpush << 'notification={
            "ios":{
                 "alert":"你捕获了一个赞，戳进来看看",
                 "content-available":1,
                 "extras":{"type": "tweet_like", "msg": "你捕获了一个赞，戳进来看看", "tweet_id": "'+tweet.id.to_s+'" }
                   }
                }'

        jpush << 'message={ "msg_content" : "你捕获了一个赞，戳进来看看", "title": "你捕获了一个赞，戳进来看看", "extras": {"type": "tweet_like", "msg": "你捕获了一个赞，戳进来看看", "tweet_id": "'+tweet.id.to_s+'" }

        }'

        jpush << 'options={"time_to_live":60,"apns_production" : '+APNS_PRODUCTION+'}'
        req.body = jpush.join("&")
        resp = http.request(req)
        puts resp
        #添加消息通知
        message = Message.create(:type => 'tweet_like', :user_id => tweet.user_id, :from_user_id => from_user_id, :tweet_id => tweet.id, :status => 0, :content => '你有一个新点赞')
      end
    end 
  end

  def self.convert_edition(key)
    case key.to_i
      when 1 then return KEY,SEC
      when 2 then return TEACHERKEY,TEACHERSEC
      when 3 then return SCHOOLKEY,SCHOOLSEC
      when 4 then return SHOPKEY,SHOPSEC
      when 5 then return CHANNELKEY,CHANNELSEC
    end
  end

end

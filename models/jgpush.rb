# 极光推送
class JGPush
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

  URL = URI('https://api.jpush.cn/v3/push')

  #新预约通知 您有一个新订单，立即处理
  def self.order_confirm order_id
    order = Order.get order_id

    current_alias = "teacher_"+order.teacher_id.to_s

    jpush = JPush::Client.new(TEACHERKEY,TEACHERSEC)

    pusher = jpush.pusher

    audience = JPush::Push::Audience.new.set_alias(current_alias)

    extras   = {type: "order_confirm", msg: "您有一个新订单", order_id: order_id}

    notification = JPush::Push::Notification.new.
        set_android(
            alert: "您有一个新的约车订单",
            title: "来新订单了",
            extras: extras
        ).set_ios(
        alert: "您有一个新的约车订单",
        available: true,
        extras: extras
    )

    push_payload = JPush::Push::PushPayload.new(
        platform: 'all',
        audience: audience,
        notification: notification,
    ).set_message(
        "您有一个新的约车订单",
        title: "来新订单了",
        content_type: 'text',
        extras: extras
    )

    begin
      pusher.push(push_payload)
    rescue
      {status: :failure, msg: '推送失败'}.to_json
    end

  end #order_confirm

  #订单被学员取消了
  def self.order_cancel order_id

    order = Order.get order_id

    if order.order_confirm && order.order_confirm.status != 2

      #学员取消预订 则推送给教练

      current_alias = "teacher_"+order.teacher_id.to_s

      jpush = JPush::Client.new(TEACHERKEY,TEACHERSEC)

      pusher = jpush.pusher

      audience = JPush::Push::Audience.new.set_alias(current_alias)

      extras   = {type: "order_cancel", msg: "学员取消了订单，立即查看", order_id: order_id}

      notification = JPush::Push::Notification.new.
          set_android(
              alert: "学员取消了订单，立即查看",
              title: "学员取消订单",
              extras: extras
          ).set_ios(
          alert: "学员取消了订单，立即查看",
          available: true,
          extras: extras
      )

      push_payload = JPush::Push::PushPayload.new(
          platform: 'all',
          audience: audience,
          notification: notification
      ).set_message(
          "学员取消了订单，立即查看",
          title: "学员取消订单",
          content_type: 'text',
          extras: extras
      )

    end

    begin
      pusher.push(push_payload)
    rescue
      {status: :failure, msg: '推送失败'}.to_json
    end

  end #order_cancel

  #学员完成评价 推送给教练
  def self.order_comment order_id 
    order = Order.get order_id

    current_alias = "teacher_"+order.teacher_id.to_s

    jpush = JPush::Client.new(TEACHERKEY,TEACHERSEC)

    pusher = jpush.pusher

    audience = JPush::Push::Audience.new.set_alias(current_alias)

    extras   = {type: "order_comment", msg: "学员评价了您，戳进来看看", order_id: order_id }

    notification = JPush::Push::Notification.new.
        set_android(
            alert: "学员评价了您，戳进来看看",
            title: "学员评价",
            extras: extras
        ).set_ios(
        alert: "学员评价了您，戳进来看看",
        available: true,
        extras: extras
    )

    push_payload = JPush::Push::PushPayload.new(
        platform: 'all',
        audience: audience,
        notification: notification
    ).set_message(
        msg_content: "学员评价了您，戳进来看看",
        title: "学员评价",
        content_type: 'text',
        extras: extras
    )

    begin
      pusher.push(push_payload)
    rescue
      {status: :failure, msg: '推送失败'}.to_json
    end
        
    TeacherNotice.create(:teacher_id => order.teacher_id, :type => 'order_comment', :note => "学员评价了您，戳进来看看", :value => order.id )

  end #order_comment

  def self.tweet_comment(tweet_id, from_user_id, reply_user_id=nil, content='')
    tweet = Tweet.get tweet_id
    return false if tweet.nil?

    #如果评论的用户不是推主 则推送评论通知
    if from_user_id != tweet.user_id

      current_alias = "user_"+tweet.user_id.to_s

      jpush1 = JPush::Client.new(KEY,SEC)

      pusher1 = jpush1.pusher

      audience = JPush::Push::Audience.new.set_alias(current_alias)

      extras   = {type: "tweet_comment", msg: "你收到了新的评论，戳进来看看", tweet_id: tweet_id }

      notification = JPush::Push::Notification.new.
          set_android(
              alert: "你收到了新的评论，戳进来看看",
              title: "动态评价",
              extras: extras
          ).set_ios(
          alert: "你收到了新的评论，戳进来看看",
          available: true,
          extras: extras
      )

      push_payload1 = JPush::Push::PushPayload.new(
          platform: 'all',
          audience: audience,
          notification: notification
      ).set_message(
          msg_content: "你收到了新的评论，戳进来看看",
          title: "动态评价",
          content_type: 'text',
          extras: extras
      )

      #添加消息通知
      Message.create(:type => 'tweet_comment', :user_id => tweet.user_id, :from_user_id => from_user_id, :tweet_id => tweet.id, :status => 0, :content => content)

      begin
        pusher1.push(push_payload1)
      rescue
        {status: :failure, msg: '推送失败'}.to_json
      end

    end

    #如果回复的用户不是推主 则推送评论通知
    if reply_user_id && reply_user_id.to_i != tweet.user_id

      current_alias = "user_"+reply_user_id.to_s

      jpush2 = JPush::Client.new(KEY,SEC)

      pusher2 = jpush2.pusher

      audience = JPush::Push::Audience.new.set_alias(current_alias)

      extras   = {type: "tweet_reply", msg: "你收到了新的评论，戳进来看看", tweet_id: tweet_id }

      notification = JPush::Push::Notification.new.
          set_android(
              alert: "你收到了新的回复，戳进来看看",
              title: "动态回复",
              extras: extras
          ).set_ios(
          alert: "你收到了新的回复，戳进来看看",
          available: true,
          extras: extras
      )

      push_payload2 = JPush::Push::PushPayload.new(
          platform: 'all',
          audience: audience,
          notification: notification
      ).set_message(
          msg_content: "你收到了新的回复，戳进来看看",
          title: "动态回复",
          content_type: 'text',
          extras: extras
      )

      #添加消息通知
      Message.create(:type => 'tweet_reply', :user_id => reply_user_id, :from_user_id => from_user_id, :reply_user_id => reply_user_id, :tweet_id => tweet.id, :status => 0, :content => content)

      begin
        pusher2.push(push_payload2)
      rescue
        {status: :failure, msg: '推送失败'}.to_json
      end

    end

  end #tweet_comment end

  def self.tweet_like(tweet_id, from_user_id)
    tweet = Tweet.get tweet_id
    return false if tweet.nil?
    if from_user_id != tweet.user_id
      current_alias = "user_"+tweet.user_id.to_s

      jpush = JPush::Client.new(KEY,SEC)

      pusher = jpush.pusher

      audience = JPush::Push::Audience.new.set_alias(current_alias)

      extras   = {type: "tweet_like", msg: "你捕获了一个赞，戳进来看看", tweet_id: tweet_id }

      notification = JPush::Push::Notification.new.
          set_android(
              alert: "你捕获了一个赞，戳进来看看",
              title: "动态被赞",
              extras: extras
          ).set_ios(
          alert: "你捕获了一个赞，戳进来看看",
          available: true,
          extras: extras
      )

      push_payload = JPush::Push::PushPayload.new(
          platform: 'all',
          audience: audience,
          notification: notification
      ).set_message(
          msg_content: "你捕获了一个赞，戳进来看看",
          title: "动态被赞",
          content_type: 'text',
          extras: extras
      )

      Message.create(:type => 'tweet_like', :user_id => tweet.user_id, :from_user_id => from_user_id, :tweet_id => tweet.id, :status => 0, :content => '你有一个新点赞')

      begin
        pusher.push(push_payload)
      rescue
        {status: :failure, msg: '推送失败'}.to_json
      end

    end 
  end
end

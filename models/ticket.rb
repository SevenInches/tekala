class Ticket
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial
  property :user_id, Integer
  property :open_id, String
  property :content, Text
  property :created_at, DateTime
  property :updated_at, DateTime
  property :tags, String
  property :type, Integer, :default => 0 #0: 代表用户问题，1:系统回复
  property :close, Integer, :default => 0 #0: 未完成 ，1:已完成
  property :note, String
  property :city, String

  belongs_to :user

  after :save, :ticket_save

  def ticket_save 
    #保存后将同一open_id的其他条目都改为已经回复
    Ticket.all(:open_id => open_id, :close => 0, :id.lt => id).each do |ticket|
      ticket.close = 1
      ticket.save
    end

  end

  def close_word
    close > 0 ? '是' : '否'
  end

  def created_at_format
    created_at.strftime("%Y-%m-%d %H:%M")
  end
  
  def self.unfinish_question
    Ticket.all(:type=>0, :close=>0)
  end

  def question?
    type == 0
  end

  def reply(content)
    ticket = Ticket.new
    ticket.type = 1
    ticket.content = content
    ticket.user_id = user_id
    ticket.open_id = open_id
    ticket.city    = city
    ticket.close   = 1
    ticket.save

    update(:close => 1)

    #发送微信
    # mm_app_id     = CustomConfig::APPID
    # mm_app_secret = CustomConfig::SECRET
    mm_app_id     = "wx1749b60f3dddf1d4"
    mm_app_secret = "230dcf200f717e0455d9781503e570d7"

    weixin_token   = ParamsConfig.first_or_create(:name => 'weixin')
    if weixin_token.value.nil? || weixin_token.updated_at.to_i+200 < Time.now().to_i
      
      access_token = WeixinJsSDK::AccessToken.new(
        app_id:     mm_app_id,
        app_secret: mm_app_secret
      ).fetch
      weixin_token.value = access_token
      weixin_token.save
    else
       access_token = weixin_token.value
    end

      @reply_content = '{
                    "touser":"'+open_id+'",
                    "msgtype":"text",
                    "text":
                    {
                         "content":"'+content+'"
                    }
                }'

      @url  = "https://api.weixin.qq.com/cgi-bin/message/custom/send?access_token=#{access_token}"
      puts RestClient.post @url, @reply_content

      return true

  end
end

class Notification
  include DataMapper::Resource

  KEY = CustomConfig::JPKEYTEST
  SEC = CustomConfig::JPSECTEST
  URL = URI(CustomConfig::JPURL)
  property :id, Serial
  property :title, String, :default => ''
  property :description, String, :default => ''
  property :version, String
  property :type, String
  property :user_id, Text
  property :city, String
  property :url, String
  property :remark, Text
  property :response, Text
  property :created_at, DateTime

  after :create, :push_client 

  def push_client 
  	tag           = []
  	user_alias    = []
    type_array    = []
    version_array = []
  	my_alias      = ''
  	my_tag        = ''
  	if user_id.to_s.gsub(/\s/, '').empty?
	  	if type && !type.empty?
        
        type_array << type.split(',').uniq.map {|val| '"type_'+val+'"'}
        type_array.each do |arr|
          tag << arr
        end

      end

      if version && !version.empty?
        version_array << version.split(',').uniq.map {|val| '"version_'+val+'"'}
        version_array.each do |arr|
          tag << arr
        end
        
      end

	  	my_tag = "["+tag.join(",")+"]"
	  	audience = 'audience={"tag":'+my_tag+'}' 
    else
    	user_alias << user_id.split(',').uniq.map {|val| '"user_'+val+'"'}
    	my_alias = "["+user_alias.join(",")+"]"
	  	audience = 'audience={"alias" : '+my_alias+'}' 
    end

  	Net::HTTP.start(URL.host, URL.port,:use_ssl => URL.scheme == 'https') do |http|
        req=Net::HTTP::Post.new(URL.path)
        req.basic_auth KEY,SEC
        jpush =[]
        jpush << 'platform=all'
        jpush << audience

        jpush << 'notification={
            "ios":{
                   "alert":"'+title+'",
                   "content-available":1,
                   "sound": "default",
                   "badge": "1",
                   "extras":{"type": "sys_notification", "notification_id":"'+id.to_s+'", "url": "'+url+'", "title": "'+title+'", "description": "'+description+'" }
                     }
                  }'
        jpush << 'message={ "msg_content" : "'+title+'","content_type":"sys_notification", "title": "'+title+'", "extras": {"type": "sys_notification", "notification_id":"'+id.to_s+'", "url": "'+url+'", "title": "'+title+'", "description": "'+description+'" }

        }'
        jpush << 'options={"time_to_live":60,"apns_production" : false}'
        req.body = jpush.join("&")
        resp=http.request(req)
        self.update(:response => resp.body, :remark => req.body)
    end

  end


  def date_format 
    created_at.strftime('%Y-%m-%d %H:%I:%S')
  end


end

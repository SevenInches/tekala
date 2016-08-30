# -*- encoding : utf-8 -*-
class CustomConfig
	HOST      = Padrino.env == :development ? 'http://localhost:9000' : 'http://www.tekala.cn'
	APPID     = 'wx2518632f280d206d'
	SECRET    = "b0d8eda74319a5984cfce9f230eab6b9"
	
	WHAPPID   = 'wxc4f49bfef9b7c698'
  WHSECRET  = 'bb7b995d7d7d130e19d3a96986a46ddc'

	INSURE    = "http://121.15.1.122:9001/ThirdPartPlat/execute.action"
	
	# HOST    = 'http://172.168.1.120:9000'
	PINGLIVE  = "sk_live_wesz5JuMZxfVLO1GNI57K9x9"
	PINGTEST  = "sk_test_vzbPqTG0GqT8LqLCyPHmf9mL"
	PINGAPPID = "app_H8Se90L8mLaDWPWn"
	
	#极光推送
	JPKEYTEST = '5b07a33a8316d8fa9015e419'
	JPSECTEST = '7055158a46cc5904917e0571'
	JPURL     = 'https://api.jpush.cn/v3/push'
	
	EMAILSMTP =  'smtp.qq.com'
	EMAILPORT =  25
	EMAILADD  =  '362648934@qq.com'
	EMAILPWD  =  ''
	
	#发送短信
	SMSADD    = "http://www.jc-chn.cn/smsSend.do"
	SMSNAME   = 'tkl'
	SMSPWD    = 'rju978ju'
	
	QINIUURL    = 'http://7xlvuu.com1.z0.glb.clouddn.com/'
	QINIUBUCKET = "mmxueche"

	SENDCLOUDUSER = "mmxueche_service"
	SENDCLOUDKEY  = "ZfJF6wvqa3zKkfgN"

	EXAMLISTMAIN = 'http://app.stc.gov.cn:8090/kszzyy/'
	VERIFYCODE   = 'verifyCode.action'
	EXAMLISTPAGE = 'reportout_getddPdListNew.action'

	PAY_APPID = 'wxbf810e4e6d170b3f'
	PAY_SECRET= "4e7bf1de38c0f2242cc46f1e58c4a4cd"
	
	def self.pingxx
      Pingpp.api_key = (Padrino.env == :production) ? PINGLIVE : PINGTEST
  end

end

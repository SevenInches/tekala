# require 'digest/sha1'
#  class WechatSupports
#   @@token="57da3489d656b7aa"  
#   def auth_wechat  
#     if check_signature?(params[:signature],params[:timestamp],params[:nonce]) 
#      puts "========params[:echostr]" 
#      puts params[:echostr] 
#      puts "========params[:echostr]" 
#      return render text: params[:echostr]  
#     end  
#   end  
#  private  
#   def check_signature?(signature,timestamp,nonce)  
#   	puts "====[timestamp,nonce,@@token].sort.join"
#   	puts [timestamp,nonce,@@token].sort.join
#   	puts "====[timestamp,nonce,@@token].sort.join"
#     Digest::SHA1.hexdigest([timestamp,nonce,@@token].sort.join) == signature  
#   end  
#  end 
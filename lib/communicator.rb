require 'twilio-ruby' 
module Communicator
  def self.send_with_phone(phone, content)
    # put your own credentials here 
    account_sid = 'AC6add4d076029cb640970525a0c9377ec' 
    auth_token = 'adb9b8f5688468c71ea82cdc8c882e5c' 
      # set up a client to talk to the Twilio REST API 
    begin
      @client = Twilio::REST::Client.new account_sid, auth_token 
       
      @client.account.messages.create({
        :from => '+19287233062', 
        :to => "+86#{phone}", 
        :body => content,  
        :status_callback => 'http://www.mmxueche.com/'
      })
    rescue Exception => e
      return false
    end   
        
  end
end
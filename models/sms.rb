# class Sms
#   include DataMapper::Resource

#   # property <name>, <type>
#   property :id, Serial
#   property :mobile, String, :required => true,
#          :messages => {:presence  => "手机号不能为空"}
#   property :content, String, :required => true,
#          :messages => {:presence  => "内容不能为空"}
#   property :account_id, Integer
#   property :created_at, DateTime
# end

class Manager
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial
  property :created_at, DateTime
  property :updated_at, DateTime
  property :school_id, Integer
  property :name, String
  property :mobile, String
  property :email, String
  property :crypted_password, String
  property :role, Integer
  property :status, Integer

  # 用户添加日志
  def add_log(type, content, target=nil)
    Log.add(self, school_id, type, content, target)
  end
  
end

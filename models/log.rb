class Log
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial
  property :created_at, DateTime
  property :school_id, Integer

  # 操作人
  property :role, String
  property :role_id, Integer
  
  # 类型 -1是删除，0是修改，1是添加，2是搜索，3是浏览
  TYPE = {:delete=>-1, :modify=>0, :add=>1, :search=>2, :view=>3}
  property :type, Integer

  property :content, String

  property :target_name, String
  property :target_id, Integer

  belongs_to :school

  def self.add(user, school_id, type, content, target=nil)
    log = Log.new(:school_id=>school_id)
    log.role    = user.class.to_s
    log.role_id = user.id
    log.type    = TYPE[type]
    log.content = content
    if target
      log.target_name = target.class.to_s
      log.target_id   = target.id
    end
    log.save
  end

end

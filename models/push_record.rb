class PushRecord
  include DataMapper::Resource

  # property <name>, <type>

  property :id, Serial
  property :type, Integer, :required => true
  property :content, Text, :lazy => false, :required => true,
         :messages => {:presence  => "内容不能为空"}
  property :created_at, DateTime

  #   {:android => 0, :ios => 1}
  property :type, Enum[0, 1], :default => 0 

  def self.get_type
  return {'android'=>0, 'ios'=>1}
  end

  def set_type
    case self.type
    when 0
      return 'android'
    when 1
      return 'ios'
    end
  end
end

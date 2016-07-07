class Question
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial
  property :title, String, :required => true,
           :messages => {:presence  => "问题不能为空"}
  property :content, Text, :required => true,
           :messages => {:presence  => "答案不能为空"}
  property :tag, Text, :lazy => false, :required => true,
           :messages => {:presence  => "标签不能为空"}
  property :created_at, DateTime
  #   {:学员 => 1, :教练 => 2, :驾校 =>3}
  property :type, Integer
  property :weight, Integer
  property :show, Boolean, :default =>1

  def self.get_type
      return {'学员'=>1, '教练'=>2,'驾校'=>3}
    end

  def set_type
      case self.type
        when 1
          return '学员'
        when 2
          return '教练'
        when 3
          return '驾校'
      end
    end

  def show_word
      show ? '显示' : '隐藏'
    end
end

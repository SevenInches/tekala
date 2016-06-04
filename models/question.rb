# -*- encoding : utf-8 -*-
class Question
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial
  property :title, String, :required => true,
  		   :messages => {:presence  => "问题不能为空"}
  property :content, String, :required => true,
  		   :messages => {:presence  => "答案不能为空"}
  property :tag, Text, :lazy => false, :required => true,
  		   :messages => {:presence  => "标签不能为空"}
  property :show, Boolean, :default => true

  #   {:学员 => 0, :教练 => 1}
  property :type, Enum[0, 1], :default => 0 

  property :city, String, :default => '0755'

	def self.get_type
	return {'学员'=>0, '教练'=>1}
	end

	def set_type
		case self.type
		when 0
		  return '学员'
		when 1
		  return '教练'
		end
	end

  def self.city
    return {'深圳' => '0755', '武汉' => '027', '重庆' => '023'}
  end

  def show_word 
    show ? '显示' : '隐藏'
  end
end

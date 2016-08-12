Tekala::TestForStudent.helpers do
  
  def result(status)
    if $arr.include? status
      "测试成功"
    elsif ! $arr.include? 'over'
      "还未测试成功"
    else
      "此处测试失败"
    end
  end

end
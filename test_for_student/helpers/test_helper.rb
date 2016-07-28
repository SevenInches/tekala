Tekala::TestForStudent.helpers do
  
  def result(id)
    if $arr.include? id
      "测试成功"
    else
      "还未测试成功"
    end
  end

end
Szcgs::Api.helpers do
  def empty?(data) ;data.to_s.empty? ? true : false ;end

  def city_list
  	city_file = "#{PADRINO_ROOT}/config/city.json"
  	if File.exists?(city_file)
  		str = ''
  		File.open(city_file, 'r') do |file|
	  		while line = file.gets
	  			str += line
	  		end
	  	end
	  	str
  	else
  		'{"status": "failure"}'
  	end
  	
  	
  end
end
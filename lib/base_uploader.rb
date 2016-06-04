class BaseUploader < CarrierWave::Uploader::Base
	#https://ruby-china.org/topics/21403
	storage :qiniu

	def store_dir 
		"#{model.class.to_s.underscore}"
	end

	def default_url 
		"photo/#{version_name}.jpg"
	end
	
	def qiniu_async_ops
	  commands = []
	  unless version_names.empty?
	  	version_names.each do |version|
	  		commands << "http://#{self.qiniu_bucket_domain}/#{self.model}/#{self.filename}_#{version}"
	  	end
	  end
	  commands
	end

	def filename
		if super.present?
			@name = model.try(:id) || Digest::MD5.hexdigest(current_path)
			@module = self.module_name + "/"
			"#{@module}#{Time.now.year}/#{@name}.#{file.extension.downcase}"
		end
	end
end
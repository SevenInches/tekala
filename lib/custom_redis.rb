class CustomRedis 

	def initialize hash=nil
		@redis = Redis.new(:host => "localhost", :port => 6379)
		@redis.set 'data', hash.to_json if hash
		@redis.save if hash 
	end

	def setting 
		@redis = JSON.parse(@redis.get("data"))
	end

	def setting= hash
		@redis.set 'data', hash.to_json
	end

	def save 
		@redis.save
	end

	def self.setting
		@redis = Redis.new(:host => "localhost", :port => 6379)
		JSON.parse(@redis.get("data"))
	end
end
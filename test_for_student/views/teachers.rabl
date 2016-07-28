node(:status) { 'success' }
node(:total) { @total }
child(@teachers => :data){
	 attributes :id, :rate, :name, :profile, :avatar_thumb_url, :avatar_url, :tech_type, :mobile
	 attributes :remark,     :if => lambda { |val| !val.remark.nil? }
	 attributes :price,      :if => lambda { |val| !val.price.nil?  }
	 attributes :hometown,   :if => lambda { |val| !val.hometown.nil? }
	 attributes :address,  :if => lambda { |val| !val.address.nil? }
     node(:exam_type ) { |val| @demo.present? ? val.exam_type_demo : val.exam_type }
	 node(:tech_type ) { |val| @demo.present? ? val.tech_type_demo : val.tech_type }
	 node(:sex ) { |val| @demo.present? ? val.sex_demo : val.sex }
}

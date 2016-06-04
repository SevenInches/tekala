class PayType
  include DataMapper::Resource

  property :id, Serial
  property :city, String, :required => true #城市区号
  property :name, String 
  property :note, String
  property :quantity, Integer, :default => 0 #学时限制 0为不限学时
  property :car_type, Integer, :default => 0 #0表示不限车型，1表示C1，2表示C2
  property :created_at, DateTime

  has n, :products, :model => 'Product'
  
  belongs_to :in_city, :model =>  'City', :parent_key => 'num', :child_key => 'city'

  def created_at_format 
  	created_at.strftime("%Y-%m-%d")
  end

  def car_type_limit 
    case car_type
    when 0
      '不限车型'
    when 1
      'C1'
    when 2
      'C2'
    end
  end

  def quantity_limit 
    case quantity
    when 0
      '不限学时'
    else
      "#{quantity} 学时"
    end
  end

end

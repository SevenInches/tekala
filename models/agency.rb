# 代理管理
class Agency
  include DataMapper::Resource
  require 'chinese_name'

  # property <name>, <type>
  property :id, Serial
  property :channel_id, Integer
  property :product_id, Integer
  property :amount, Integer
  property :created_at, DateTime
  property :updated_at, DateTime
  property :commission, Integer
  property :price, Integer
  property :school_name, String
  property :school_logo, String
  property :product_name, String
  property :title, String
  property :content, String
  property :icon, String

  # 这里写的不是很好，也许应该是 before :create ？
  before :save, :create_agency_fast

  # 创建一个Agency对象只需要输入channel_id和product_id
  def create_agency_fast
    # self.amount = 0

    product = Product.first(:id => product_id)
    self.commission = product.commission.nil? ? 0 : product.commission
    self.price = product.price
    self.product_name = product.name

    school_id = product.school.id
    school = School.first(:id => school_id)
    self.school_name = school.name
    self.school_logo = school.logo
  end

end
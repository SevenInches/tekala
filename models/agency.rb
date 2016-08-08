# -*- encoding : utf-8 -*-
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

  before :save, :create_agency_fast

  # 创建一个Agency对象只需要输入channel_id和product_id
  # 这里有个BUG: Encoding::CompatibilityError: incompatible character encodings: ASCII-8BIT and UTF-8
  def create_agency_fast
    self.amount = 0

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
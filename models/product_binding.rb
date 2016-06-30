class ProductBinding
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial
  property :title, String
  property :description, String
  # property :price, Float
  # property :promotion_price, Float
  property :introduction, Text
  property :c1_product_id, Integer, :default => 0
  property :c2_product_id, Integer, :default => 0
  property :c1_price, Float, :default => 0
  property :c2_price, Float, :default => 0
  property :color, String
  property :city_id, Integer, :default => 0
  property :show, Boolean, :default => false
  property :school_id, Integer, :default => 0
  property :created_at, DateTime

  has n, :product_binding_photos

  belongs_to :city

  belongs_to :school

  def city_name
    city.name
  end

  def c2_product
    Product.get(c2_product_id)
  end

  def c1_product
    Product.get(c1_product_id)
  end

  def c1
    Product.get c1_product_id
  end

  def c2
    Product.get c2_product_id
  end

  def c1_or_c2_price
    if self.c1_product.present?
      self.c1_product.price/100
    elsif self.c2_product.present?
      self.c2_product.price/100
    else
      '--'
    end
  end

  def self.colors
    {"紫色" => '#967ADC', "橙色" => "#EE6439", '蓝色' => '#4A89DC', '绿色' => '#8CC152'}
  end

  def photo_ids 
    product_binding_photos.map(&:id).join(',')
  end

  def photos
    product_binding_photos.map(&:resource_url)
  end

  def self.all_first_photos 
    photos = {}
    ProductBinding.all(:show => true).each do |pb|
      photospb = pb.product_binding_photos
      tmp = photospb.first 
      photos.store(pb.id, tmp.resource_url) if tmp
    end
    photos 

  end

  def created_at_format 
    created_at.strftime('%y-%M-%d')
  end

end

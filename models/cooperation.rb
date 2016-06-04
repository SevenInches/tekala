class Cooperation
  include DataMapper::Resource

  property :id, Serial
  property :company_name, String
  property :discount, Integer
  property :qrcode, String, :auto_validation => false
  property :logo, String, :auto_validation => false
  property :back_url, String
  property :discount_code, String
  property :created_at, DateTime
  mount_uploader :qrcode, QrcodePhoto
  mount_uploader :logo, LogoPhoto

  def qrcode_thumb_url
     qrcode.thumb && qrcode.thumb.url ? CustomConfig::HOST + qrcode.thumb.url : ''
  end

  def qrcode_url
     qrcode && qrcode.url ? CustomConfig::HOST + qrcode.url : ''
  end

  def logo_thumb_url
     logo.thumb && logo.thumb.url ? CustomConfig::HOST + logo.thumb.url : ''
  end

  def logo_url
     logo && logo.url ? CustomConfig::HOST + logo.url : ''
  end

end

class Channel
  include DataMapper::Resource
  attr_accessor :password, :password_confirmation
  property :id, Serial
  property :name, String
  property :mobile, String
  property :crypted_password, String
  property :event_key, Integer
  property :username, String
  property :qrcode, String, :auto_validation => false
  property :desc, Integer
  property :avatar, String
  property :created_at,DateTime

  mount_uploader :qrcode, ChannelQrcode

  has n, :data, :model => 'ChannelData', :child_key => :event_key, :parent_key => :event_key, :constraint => :destroy

  before :save, :encrypt_password

  def qrcode_thumb_url
     qrcode.thumb && qrcode.thumb.url ? CustomConfig::HOST + qrcode.thumb.url : nil 
  end 

  def qrcode_url
     qrcode && qrcode.url ? CustomConfig::HOST + qrcode.url : nil
  end
  

  def self.authenticate(event_key, password)
    seller = first(:conditions => ["lower(event_key) = lower(?) or lower(mobile) = lower(?)", event_key, event_key]) if event_key.present?
    seller && seller.has_password?(password) ? seller : nil
  end
  
  def self.find_by_id(id)
    get(id) rescue nil
  end

  def has_password?(password)
    ::BCrypt::Password.new(crypted_password) == password
  end


  def format_date
  	created_at.strftime('%Y-%m-%d')
  end

  def self.main_channel(channel)
    channel_hash = Hash[
        '1000'=>'线下',
        '2000'=>'线上',
        '3000'=>'口碑传播',
        '4000'=>'To B'
    ]
    if channel.nil?
      return channel_hash
    else
      return channel_hash[channel]
    end
  end

  def self.city(city)
    city_hash = Hash[
        '10'=>'深圳',
        '20'=>'武汉',
        '30'=>'重庆'
    ]
    if city.nil?
      return city_hash
    else
      return city_hash[city]
    end
  end

  def self.child_channel(main)
    case main
      when '1000' then
        return Hash[
            '0'=>'不限',
            '1'=>'传单',
            '2'=>'海报',
            '3'=>'易拉宝'
        ]
       else return {'0'=>'不限'}
    end
  end

  def self.convert_city(city)
    case city
      when '0755' then return 10
      when '027'  then return 20
      when '023'  then return 30
    end
  end
  private

  def password_required
    crypted_password.blank? || password.present?
  end

  def encrypt_password
    self.crypted_password = ::BCrypt::Password.create(password) if password.present?
  end



end

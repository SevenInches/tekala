class Hospital
  include DataMapper::Resource

  property :id, Serial
  property :city_id, Enum[0], :default => 0
  property :name, String
  property :address, String
  property :latitude, String
  property :longitude, String
  property :note, String
  property :time, String
  property :form, Boolean, :default => false
  property :phone, String
  property :created_at, DateTime

  def self.get_city
    return {'深圳市'=>'0'}
  end

  def self.form_word 
    return {"提供" => 1, "不提供" => 0 }
  end

  def form_label
    case form
    when true
      'success'
    else
      'danger'
    end
  end

  def set_city
    case self.city_id
    when 0
      return '深圳市'
    end
  end
end

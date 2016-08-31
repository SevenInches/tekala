class Device
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial
  property :device_no, String
  property :hardware_version, String
  property :software_version, String
  property :status, Integer
  property :is_active, Boolean
  property :created_at, DateTime
  property :updated_at, DateTime

  def convet_status_word
    case is_active
      when true
        return '是'
      when false
        return '否'
    end
  end
end

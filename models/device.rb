#机器人设备
class Device
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial
  property :device_no, String
  property :hardware_version, String
  property :software_version, String
  property :status, Integer
  property :is_active, Boolean, :default => true
  property :created_at, DateTime
  property :updated_at, DateTime

  before :save, :create_device_no

  def create_device_no
    if device_no.nil?
      date = created_at.strftime('%y%m%d')
      last = Device.last.id
      code = date.to_s + (last+1).to_s(32)
      no = code.rjust(8, '0')
      self.device_no = no
    end
  end
end

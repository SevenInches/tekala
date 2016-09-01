class BootLog
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial
  property :device_no, String
  property :software_version, String
  property :result, Boolean, :default => true
  property :note, Text
  property :created_at, DateTime
end

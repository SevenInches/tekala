migration 32, :create_devices do
  up do
    create_table :devices do
      column :id, Integer, :serial => true
      column :device_no, DataMapper::Property::String, :length => 255
      column :hardware_version, DataMapper::Property::String, :length => 255
      column :software_version, DataMapper::Property::String, :length => 255
      column :status, DataMapper::Property::Integer
      column :is_active, DataMapper::Property::Boolean
      column :created_at, DataMapper::Property::DateTime
      column :updated_at, DataMapper::Property::DateTime
    end
  end

  down do
    drop_table :devices
  end
end

migration 34, :create_boot_logs do
  up do
    create_table :boot_logs do
      column :id, Integer, :serial => true
      column :device_no, DataMapper::Property::String, :length => 255
      column :software_version, DataMapper::Property::String, :length => 255
      column :result, DataMapper::Property::Boolean
      column :note, DataMapper::Property::Text
      column :created_at, DataMapper::Property::DateTime
    end
  end

  down do
    drop_table :boot_logs
  end
end

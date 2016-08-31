migration 33, :create_school_devices do
  up do
    create_table :school_devices do
      column :id, Integer, :serial => true
      column :school_id, DataMapper::Property::Integer
      column :device_id, DataMapper::Property::Integer
      column :car_id, DataMapper::Property::Integer
      column :deploy_at, DataMapper::Property::Date
      column :created_at, DataMapper::Property::DateTime
      column :updated_at, DataMapper::Property::DateTime
    end
  end

  down do
    drop_table :school_devices
  end
end

migration 35, :create_login_logs do
  up do
    create_table :login_logs do
      column :id, Integer, :serial => true
      column :device_no, DataMapper::Property::String, :length => 255
      column :school_id, DataMapper::Property::Integer
      column :user_id, DataMapper::Property::Integer
      column :login_type, DataMapper::Property::Integer
      column :result, DataMapper::Property::Boolean
      column :created_at, DataMapper::Property::DateTime
    end
  end

  down do
    drop_table :login_logs
  end
end

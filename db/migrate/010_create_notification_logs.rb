migration 10, :create_notification_logs do
  up do
    create_table :notification_logs do
      column :id, Integer, :serial => true
      column :school_id, DataMapper::Property::Integer
      column :role, DataMapper::Property::Integer
      column :role_id, DataMapper::Property::Integer
      column :content, DataMapper::Property::String, :length => 255
      column :created_at, DataMapper::Property::DateTime
    end
  end

  down do
    drop_table :notification_logs
  end
end

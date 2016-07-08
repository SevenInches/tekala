migration 14, :create_logs do
  up do
    create_table :logs do
      column :id, Integer, :serial => true
      column :created_at, DataMapper::Property::DateTime
      column :school_id, DataMapper::Property::Integer
      column :role, DataMapper::Property::Integer
      column :role_id, DataMapper::Property::Integer
      column :type, DataMapper::Property::Integer
      column :content, DataMapper::Property::String, :length => 255
      column :target_name, DataMapper::Property::String, :length => 255
      column :target_id, DataMapper::Property::Integer
    end
  end

  down do
    drop_table :logs
  end
end

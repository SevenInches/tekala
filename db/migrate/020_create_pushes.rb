migration 20, :create_pushes do
  up do
    create_table :pushes do
      column :id, Integer, :serial => true
      column :message, DataMapper::Property::String, :length => 255
      column :type, DataMapper::Property::Integer
      column :value, DataMapper::Property::String, :length => 255
      column :channel_id, DataMapper::Property::Integer
      column :version, DataMapper::Property::String, :length => 255
      column :school_id, DataMapper::Property::Integer
      column :user_status, DataMapper::Property::Boolean
      column :editions, DataMapper::Property::String, :length => 255
    end
  end

  down do
    drop_table :pushes
  end
end

migration 18, :create_blocks do
  up do
    create_table :blocks do
      column :id, Integer, :serial => true
      column :created_at, DataMapper::Property::DateTime
      column :updated_at, DataMapper::Property::DateTime
      column :school_id, DataMapper::Property::Integer
      column :field_id, DataMapper::Property::Integer
      column :name, DataMapper::Property::String, :length => 255
      column :type, DataMapper::Property::Integer
      column :data, DataMapper::Property::String, :length => 255
    end
  end

  down do
    drop_table :blocks
  end
end

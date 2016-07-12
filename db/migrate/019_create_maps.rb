migration 19, :create_maps do
  up do
    create_table :maps do
      column :id, Integer, :serial => true
      column :created_at, DataMapper::Property::DateTime
      column :updated_at, DataMapper::Property::DateTime
      column :school_id, DataMapper::Property::Integer
      column :field_id, DataMapper::Property::Integer
      column :data, DataMapper::Property::Text
    end
  end

  down do
    drop_table :maps
  end
end

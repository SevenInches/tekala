migration 4, :create_cities do
  up do
    create_table :cities do
      column :id, Integer, :serial => true
      column :name, DataMapper::Property::String, :length => 255
      column :keys, DataMapper::Property::Integer
    end
  end

  down do
    drop_table :cities
  end
end

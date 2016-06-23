migration 1, :create_schools do
  up do
    create_table :schools do
      column :id, Integer, :serial => true
      column :city_id, DataMapper::Property::String, :length => 255
      column :name, DataMapper::Property::String, :length => 255
      column :address, DataMapper::Property::String, :length => 255
      column :phone, DataMapper::Property::String, :length => 255
      column :profile, DataMapper::Property::Text
      column :is_vip, DataMapper::Property::Integer
      column :is_open, DataMapper::Property::Integer
      column :weight, DataMapper::Property::Integer
      column :master, DataMapper::Property::String, :length => 255
      column :logo, DataMapper::Property::String, :length => 255
      column :found_at, DataMapper::Property::Date
      column :latitude, DataMapper::Property::String, :length => 255
      column :longitude, DataMapper::Property::String, :length => 255
      column :config, DataMapper::Property::Text
      column :note, DataMapper::Property::String, :length => 255
      column :updated_at, DataMapper::Property::DateTime
      column :created_at, DataMapper::Property::DateTime
    end
  end

  down do
    drop_table :schools
  end
end

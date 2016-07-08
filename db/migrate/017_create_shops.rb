migration 17, :create_shops do
  up do
    create_table :shops do
      column :id, Integer, :serial => true
      column :created_at, DataMapper::Property::DateTime
      column :updated_at, DataMapper::Property::DateTime
      column :name, DataMapper::Property::String, :length => 255
      column :address, DataMapper::Property::String, :length => 255
      column :longtitude, DataMapper::Property::String, :length => 255
      column :latitude, DataMapper::Property::String, :length => 255
      column :rent_amount, DataMapper::Property::Integer
      column :area, DataMapper::Property::Integer
      column :school_id, DataMapper::Property::Integer
      column :contact_user, DataMapper::Property::String, :length => 255
      column :contact_phone, DataMapper::Property::String, :length => 255
    end
  end

  down do
    drop_table :shops
  end
end

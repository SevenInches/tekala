migration 8, :create_managers do
  up do
    create_table :managers do
      column :id, Integer, :serial => true
      column :created_at, DataMapper::Property::DateTime
      column :updated_at, DataMapper::Property::DateTime
      column :school_id, DataMapper::Property::Integer
      column :name, DataMapper::Property::String, :length => 255
      column :mobile, DataMapper::Property::String, :length => 255
      column :email, DataMapper::Property::String, :length => 255
      column :crypted_password, DataMapper::Property::String, :length => 255
      column :role, DataMapper::Property::Integer
      column :status, DataMapper::Property::Integer
    end
  end

  down do
    drop_table :managers
  end
end

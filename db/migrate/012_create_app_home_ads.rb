migration 12, :create_app_home_ads do
  up do
    create_table :app_home_ads do
      column :id, Integer, :serial => true
      column :created_at, DataMapper::Property::DateTime
      column :updated_at, DataMapper::Property::DateTime
      column :cover_url, DataMapper::Property::String, :length => 255
      column :type, DataMapper::Property::String, :length => 255
      column :route, DataMapper::Property::String, :length => 255
      column :value, DataMapper::Property::String, :length => 255
      column :status, DataMapper::Property::Integer
      column :index, DataMapper::Property::Integer
      column :school_id, DataMapper::Property::Integer
    end
  end

  down do
    drop_table :app_home_ads
  end
end

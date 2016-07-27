migration 13, :create_app_launch_ads do
  up do
    create_table :app_launch_ads do
      column :id, Integer, :serial => true
      column :created_at, DataMapper::Property::DateTime
      column :updated_at, DataMapper::Property::DateTime
      column :start_time, DataMapper::Property::DateTime
      column :end_time, DataMapper::Property::DateTime
      column :cover_url, DataMapper::Property::String, :length => 255
      column :type, DataMapper::Property::Integer
      column :route, DataMapper::Property::String, :length => 255
      column :status, DataMapper::Property::Integer
      column :value, DataMapper::Property::String, :length => 255
      column :channel, DataMapper::Property::Integer
    end
  end

  down do
    drop_table :app_launch_ads
  end
end

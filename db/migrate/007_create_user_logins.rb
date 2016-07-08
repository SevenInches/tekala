migration 7, :create_user_logins do
  up do
    create_table :user_logins do
      column :id, Integer, :serial => true
      column :created_at, DataMapper::Property::DateTime
      column :updated_at, DataMapper::Property::DateTime
      column :school_id, DataMapper::Property::Integer
      column :user_id, DataMapper::Property::Integer
      column :os, DataMapper::Property::Integer
      column :version, DataMapper::Property::String, :length => 255
      column :device, DataMapper::Property::Text
    end
  end

  down do
    drop_table :user_logins
  end
end

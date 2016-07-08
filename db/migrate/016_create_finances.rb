migration 16, :create_finances do
  up do
    create_table :finances do
      column :id, Integer, :serial => true
      column :created_at, DataMapper::Property::DateTime
      column :updated_at, DataMapper::Property::DateTime
      column :school_id, DataMapper::Property::Integer
      column :type, DataMapper::Property::Integer
      column :category_id, DataMapper::Property::Integer
      column :content, DataMapper::Property::String, :length => 255
      column :amount, DataMapper::Property::Integer
      column :status, DataMapper::Property::Integer
      column :admin, DataMapper::Property::String, :length => 255
      column :admin_date, DataMapper::Property::DateTime
    end
  end

  down do
    drop_table :finances
  end
end

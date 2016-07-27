migration 21, :create_channels do
  up do
    create_table :channels do
      column :id, Integer, :serial => true
      column :school_id, DataMapper::Property::Integer
      column :gen_key, DataMapper::Property::String, :length => 255
      column :name, DataMapper::Property::String, :length => 255
      column :type, DataMapper::Property::Integer
      column :scan_count, DataMapper::Property::Integer
      column :signup_count, DataMapper::Property::Integer
      column :pay_count, DataMapper::Property::Integer
      column :refund_count, DataMapper::Property::Integer
      column :fee, DataMapper::Property::Integer
      column :created_at, DataMapper::Property::DateTime
      column :updated_at, DataMapper::Property::DateTime
    end
  end

  down do
    drop_table :channels
  end
end

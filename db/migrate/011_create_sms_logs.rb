migration 11, :create_sms_logs do
  up do
    create_table :sms_logs do
      column :id, Integer, :serial => true
      column :created_at, DataMapper::Property::DateTime
      column :updated_at, DataMapper::Property::DateTime
      column :school_id, DataMapper::Property::Integer
      column :content, DataMapper::Property::String, :length => 255
      column :status, DataMapper::Property::Integer
      column :receiver, DataMapper::Property::String, :length => 255
      column :mobile, DataMapper::Property::String, :length => 255
    end
  end

  down do
    drop_table :sms_logs
  end
end

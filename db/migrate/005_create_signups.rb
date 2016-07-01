migration 5, :create_signups do
  up do
    create_table :signups do
      column :id, Integer, :serial => true
      column :user_id, DataMapper::Property::Integer
      column :teacher_id, DataMapper::Property::Integer
      column :train_field_id, DataMapper::Property::Integer
      column :school_id, DataMapper::Property::Integer
      column :order_no, DataMapper::Property::String, :length => 255
      column :amount, DataMapper::Property::Float, :default => 0.0
      column :discount, DataMapper::Property::Float, :default => 0.0
      column :pay_at, DataMapper::Property::DateTime
      column :done_at, DataMapper::Property::DateTime
      column :cancel_at, DataMapper::Property::DateTime
      column :created_at, DataMapper::Property::DateTime
      column :updated_at, DataMapper::Property::DateTime
      column :has_insure, DataMapper::Property::Integer, :default => 0
      column :ch_id, DataMapper::Property::String, :length => 255
      column :city_id, DataMapper::Property::Integer
      column :product_id, DataMapper::Property::Integer
      column :pay_channel, DataMapper::Property::String, :length => 255
      column :status, DataMapper::Property::Integer, :default => 0
      column :exam_type, DataMapper::Property::Integer, :default => 1
    end
  end

  down do
    drop_table :signups
  end
end

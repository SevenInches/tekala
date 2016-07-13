migration 15, :create_finance_reports do
  up do
    create_table :finance_reports do
      column :id, Integer, :serial => true
      column :created_at, DataMapper::Property::DateTime
      column :updated_at, DataMapper::Property::DateTime
      column :start_date, DataMapper::Property::DateTime
      column :end_date, DataMapper::Property::DateTime
      column :title, DataMapper::Property::String, :length => 255
      column :income, DataMapper::Property::Integer
      column :outgoings, DataMapper::Property::Integer
      column :admin, DataMapper::Property::String, :length => 255
      column :note, DataMapper::Property::Text
      column :school_id, DataMapper::Property::Integer
    end
  end

  down do
    drop_table :finance_reports
  end
end

migration 9, :create_finance_categories do
  up do
    create_table :finance_categories do
      column :id, Integer, :serial => true
      column :school_id, DataMapper::Property::Integer
      column :name, DataMapper::Property::String, :length => 255
    end
  end

  down do
    drop_table :finance_categories
  end
end

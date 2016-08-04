migration 24, :create_agency do
  up do
  	create_table :agencies do
  		column :id, Integer, :serial => true
	      	column :channel_id, DataMapper::Property::Integer
	      	column :product_id, DataMapper::Property::Integer
	      	column :amount, DataMapper::Property::Integer
	      	column :created_at, DataMapper::Property::DateTime
	      	column :updated_at, DataMapper::Property::DateTime
	      end
  end

  down do
  	drop_table :agencies
  end
end
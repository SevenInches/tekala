migration 27, :add_many_to_agency do
  up do
  	modify_table :agencies do
  		add_column :commission, Integer
  		add_column :price, Integer
  		add_column :school_name, Integer
  		add_column :school_logo, Integer
  		add_column :product_name, Integer
  	end
  end

  down do
  	modify_table :agencies do
  		drop_column :commission
  		add_column :price
  		add_column :school_name
  		add_column :school_logo
  		add_column :product_name
  	end
  end
end
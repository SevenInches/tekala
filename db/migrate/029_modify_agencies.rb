migration 29, :modify_agencies do
  up do
  	modify_table :agencies do
  		change_column :school_name, String
  		change_column :product_name, String
  	end
  end

  down do
  end
end
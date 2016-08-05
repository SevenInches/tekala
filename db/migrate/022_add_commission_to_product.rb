migration 22, :add_commission_to_product do
  up do
  	modify_table :products do
  		add_column :commission, Integer
  	end
  end

  down do
  	modify_table :products do
  		drop_column :commission
  	end
  end
end
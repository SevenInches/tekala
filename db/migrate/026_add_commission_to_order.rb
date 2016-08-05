migration 26, :add_commission_to_order do
  up do
  	modify_table :orders do
  		add_column :commission, Integer
  	end
  end

  down do
  	modify_table :products do
  		drop_column :commission
  	end
  end
end

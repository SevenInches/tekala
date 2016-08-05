migration 28, :add_sales_this_month_to_channel do
  up do
  	modify_table :channels do
  		add_column :sales_this_month, Integer
  	end
  end

  down do
  	modify_table :channels do
  		drop_column :sales_this_month
  	end
  end
end
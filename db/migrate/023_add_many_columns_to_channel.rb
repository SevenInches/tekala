migration 23, :add_many_columns_to_channel do
  up do
  	modify_table :channels do
  		add_column :contact_phone, String
  		add_column :logo, String
  		add_column :config, DataMapper::Property::Text
  		add_column :crypted_password, String
  		add_column :total_earn, Integer
  	end
  end

  down do
  	modify_table :channels do
  		drop_column :contact_phone
  		drop_column :logo
  		drop_column :config
  		drop_column :crypted_password
  		drop_column :total_earn
  	end
  end
end
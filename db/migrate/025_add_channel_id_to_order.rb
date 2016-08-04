migration 25, :add_channel_id_to_order do
  up do
  	modify_table :orders do
  		add_column :channel_id, Integer
  	end
  end

  down do
  	modify_table :products do
  		drop_column :channel_id
  	end
  end
end
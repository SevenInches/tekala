migration 30, :add_channel_id_to_user do
  up do
  	modify_table :users do
  		add_column :channel_id, Integer
  	end
  end

  down do
  	modify_table :users do
  		drop_column :channel_id
  	end
  end
end
migration 2, :add_school_to_product do
  up do
    modify_table :products do
      add_column :school_id, Integer
    end
  end

  down do
    modify_table :products do
      drop_column :school_id
    end
  end
end

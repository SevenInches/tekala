migration 3, :add_exam_type_to_product do
  up do
    modify_table :products do
      add_column :exam_type, Integer
    end
  end

  down do
    modify_table :products do
      drop_column :exam_type
    end
  end
end

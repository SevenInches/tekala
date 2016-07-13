migration 20, :add_contact_phone_to_school do
  up do
    modify_table :schools do
      add_column :contact_phone, String
    end
  end

  down do
    modify_table :schools do
      drop_column :contact_phone
    end
  end
end

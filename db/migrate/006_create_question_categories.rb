migration 6, :create_question_categories do
  up do
    create_table :question_categories do
      column :id, Integer, :serial => true
      column :created_at, DataMapper::Property::DateTime
      column :updated_at, DataMapper::Property::DateTime
      column :school_id, DataMapper::Property::Integer
      column :name, DataMapper::Property::String, :length => 255
    end
  end

  down do
    drop_table :question_categories
  end
end

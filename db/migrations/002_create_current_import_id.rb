Sequel.migration do
  change do
    create_table(:current_imports) do
      primary_key :id
      column :table, :varchar, null: false, unique: true
      column :import_id, :uuid, null: false
    end
  end
end
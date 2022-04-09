Sequel.migration do
  change do
    create_table(:states) do
      primary_key :id
      column :abbreviation, :varchar, null: false
      column :name, :varchar, null: false
      column :slug, :varchar, null: false

      index :slug, unique: true
    end
  end
end

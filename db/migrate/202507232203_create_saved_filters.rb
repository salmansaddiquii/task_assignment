class CreateSavedFilters < ActiveRecord::Migration[7.0]
  def change
    create_table :saved_filters do |t|
      t.references :user, foreign_key: true, null: true
      t.string :filterable_type, null: false
      t.jsonb :parameters, null: false, default: {}
      t.string :name
      t.timestamps
    end
    add_index :saved_filters, [:user_id, :filterable_type]
  end
end
